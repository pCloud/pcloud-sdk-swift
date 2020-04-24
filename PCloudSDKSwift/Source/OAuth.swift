//
//  OAuth.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Executes UI-specific actions related to the OAuth authorization flow.
public protocol OAuthAuthorizationFlowView {
	/// Presents a web view to the user showing a page at a specific address. The web view should forward navigation actions
	/// and the user attempting to exit the web view to the provided blocks.
	///
	/// - parameter url: The address to open in the web view.
	/// - parameter interceptNavigation: A block to be called when the web view attempts a redirection. The block should
	/// be invoked with the destination address. Returns `true` when the web view should cancel the redirection, and `false` otherwise.
	/// The block must be called on the main thread.
	/// - parameter didCancel: A block to be called when the user attempts to exit the web view by means of a button, gesture, etc.
	/// The block must be called on the main thread.
	func presentWebView(url: URL, interceptNavigation: @escaping (URL) -> Bool, didCancel: @escaping () -> Void)
	
	/// Dismisses the web view presented using
	/// `presentWebView(:interceptNavigation:didCancel:)`
	func dismissWebView()
}


/// OAuth namespace.
public struct OAuth {
	/// The result of an authorization attempt.
	public enum Result {
		case success(User)
		case failure(Error)
		case cancel
	}
	
	/// An authenticated user.
	public struct User: Codable, Equatable {
		/// A unique user identifier.
		public let id: UInt64
		
		/// An OAuth access token.
		public let token: String
		
		/// Uniquely identifies the server region hosting the user's account. You can use the `APIServerRegion` enum to make sense of these.
		public let serverRegionId: UInt
		
		/// The host name of the primary HTTP API at the user's server region.
		public let httpAPIHostName: String
	}
	
	/// A failed authorization as per RFC 6749.
	public enum Error: String, Swift.Error {
		/// The request is missing a required parameter, includes an invalid parameter value, includes a parameter more than
		/// once, or is otherwise malformed.
		case invalidRequest = "invalid_request"
		
		/// The client is not authorized to request an access token using this method.
		case unauthorizedClient = "unauthorized_client"
		
		/// The resource owner or authorization server denied the request.
		case accessDenied = "access_denied"
		
		/// The authorization server does not support obtaining an access token using this method.
		case unsupportedResponseType = "unsupported_response_type"
		
		/// The requested scope is invalid, unknown, or malformed.
		case invalidScope = "invalid_scope"
		
		/// The authorization server encountered an unexpected condition that prevented it from fulfilling the request.
		case serverError = "server_error"
		
		///  The authorization server is currently unable to handle the request due to a temporary overloading or maintenance
		/// of the server.
		case temporarilyUnavailable = "temporarily_unavailable"
		
		/// Unexpected error.
		case unknown = "unknown"
	}
	
	/// Attempts to authorize via OAuth.
	///
	/// - parameter view: An object handling UI-specific actions related to the authorization flow.
	/// - parameter appKey: An app key.
	/// - parameter completionToken: A block called when authorization completes. Called on the main thread.
	public static func performAuthorizationFlow(with view: OAuthAuthorizationFlowView, appKey: String, completionBlock: @escaping (Result) -> Void) {
		// Create URL.
		let authorizationURL = createAuthorizationURL(withAppKey: appKey, redirectURL: createRedirectURL(withAppKey: appKey))
		
		// Define callbacks.
		let interceptBlock: (URL) -> Bool = { url in
			if let result = handleRedirectURL(url, appKey: appKey) {
				// This is an OAuth redirect.
				view.dismissWebView()
				completionBlock(result)
				return true
			}
			
			return false
		}
		
		let cancelBlock = {
			view.dismissWebView()
			completionBlock(.cancel)
		}
		
		// Present the web view.
		view.presentWebView(url: authorizationURL, interceptNavigation: interceptBlock, didCancel: cancelBlock)
	}
	
	/// Fetches the first `OAuth.User` found in the keychain. Do not rely on which, specifically, that user is.
	/// If you're looking for a specific user, use `getUser(withId:)`.
	///
	/// - returns: A `OAuth.User`.
	public static func getAnyUser() -> User? {
		if let userId = Keychain.getAllKeys().first.flatMap(userId) {
			return getUser(withId: userId)
		}
		
		return nil
	}
	
	/// Fetches a `OAuth.User` object from the keychain using a user id.
	///
	/// - parameter id: A unique user identifier.
	/// - returns: A User object, or `nil`, if there is no user mapped to the provided user id.
	public static func getUser(withId id: UInt64) -> User? {
		let key = keychainKeyForUser(id)
		
		guard let data = Keychain.getData(forKey: key) else {
			return nil
		}
		
		if let user = User(jsonRepresentation: data) {
			return user
		}
		
		// There is data in the keychain for this user but is not a JSON object.
		// This should be an access token from v2 of the SDK.
		
		guard let token = String(bytes: data, encoding: .utf8) else {
			// Corrupted data maybe? This shouldn't really happen. Anyway, we can't do anything with this entry. Delete it.
			Keychain.deleteData(forKey: key)
			return nil
		}
		
		// Since this token is stored using v2 of the SDK, this must be a US user.
		let user = User(id: id, token: token, serverRegionId: APIServerRegion.unitedStates.rawValue, httpAPIHostName: "api.pcloud.com")
		store(user) // Overwrite the keychain entry.
		
		return user
	}
	
	/// Stores a `OAuth.User` object in the keychain against its unique identifier.
	///
	/// - parameter user: The user to store in the keychain.
	public static func store(_ user: User) {
		Keychain.set(user.jsonRepresentation, forKey: keychainKeyForUser(user.id))
	}
	
	/// Deletes the data associated with a specific user.
	///
	/// - parameter id: The unique user identifier.
	public static func deleteUser(withId id: UInt64) {
		Keychain.deleteData(forKey: keychainKeyForUser(id))
	}
	
	/// Deletes all users from the keychain.
	public static func deleteAllUsers() {
		for key in Keychain.getAllKeys() {
			Keychain.deleteData(forKey: key)
		}
	}
	
	// Creates a redirect URL using and app key.
	static func createRedirectURL(withAppKey appKey: String) -> URL {
		var components = URLComponents()
		components.scheme = "pclsdk-w-\(appKey.lowercased())"
		components.host = "oauth2redirect"
		
		return components.url!
	}
	
	// Creates an authorization URL from an app key for the implicit grant flow.
	static func createAuthorizationURL(withAppKey appKey: String, redirectURL: URL) -> URL {
		var components = URLComponents()
		components.scheme = URLScheme.https.rawValue
		components.host = "e.pcloud.com"
		components.path = "/oauth2/authorize"
		components.queryItems = [
			URLQueryItem(name: "client_id", value: appKey),
			URLQueryItem(name: "response_type", value: "token"),
			URLQueryItem(name: "redirect_uri", value: redirectURL.absoluteString)
		]
		
		return components.url!
	}
	
	// Checks if the provided url is a redirect url and if it is, tries to extract a result from its fragment.
	static func handleRedirectURL(_ url: URL, appKey: String) -> Result? {
		let redirectURL = createRedirectURL(withAppKey: appKey)
		
		guard url.scheme == redirectURL.scheme && url.host == redirectURL.host else {
			return nil
		}
		
		return extractResult(from: url)
	}
	
	// Extracts a result from a redirection URL.
	static func extractResult(from url: URL) -> Result {
		// As of the time of writing this (December 2016), this is how the pCloud API manages access denied - it does not send a fragment.
		guard let fragment = url.fragment else {
			return .failure(.accessDenied)
		}
		
		// Convert fragment parameters to key value pairs.
		var parameters: [String: String] = [:]
		
		for pair in fragment.components(separatedBy: "&") {
			let components = pair.components(separatedBy: "=")
			parameters[components[0]] = components[1]
		}
		
		// Handle errors.
		if let errorCode = parameters["error"] {
			if let error = Error(rawValue: errorCode) {
				return .failure(error)
			}
			
			return .failure(.unknown)
		}
		
		// Expect that if there is no error, there must be an access token.
		let token = parameters["access_token"]!
		let userId = parameters["userid"]!
		let locationId = parameters["locationid"]!
		let httpHostName = parameters["hostname"]!
		let user = User(id: UInt64(userId)!, token: token, serverRegionId: UInt(locationId)!, httpAPIHostName: httpHostName)
		
		return .success(user)
	}
	
	// Computes keychain key from a user id.
	private static func keychainKeyForUser(_ userId: UInt64) -> String {
		return "\(userId)"
	}
	
	private static func userId(fromKey key: String) -> UInt64? {
		return UInt64(key)
	}
}

extension OAuth.Result: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .success(user): return "SUCCESS: \(user)"
		case let .failure(error): return "FAILURE: \(error)"
		case .cancel: return "CANCELLED"
		}
	}
}

private extension OAuth.User {
	var jsonRepresentation: Data {
		try! JSONEncoder().encode(self)
	}
	
	init?(jsonRepresentation: Data) {
		do {
			self = try JSONDecoder().decode(OAuth.User.self, from: jsonRepresentation)
		} catch {
			return nil
		}
	}
}
