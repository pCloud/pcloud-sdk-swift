//
//  PCloud.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Convenience namespace for the SDK. Hosts a global `PCloudClient` instance.
public enum PCloud {
	/// A global client instance. Automatically initialized either inside `setUp()` or `authorize()`.
	/// Access on the main thread only.
	private(set) public static var sharedClient: PCloudClient?
	
	/// The app key provided in `setUp()`.
	private(set) public static var appKey: String?
	
	/// Attempts to initialize a pCloud client instance by checking for an existing user in the keychain.
	/// The `sharedClient` property will be non-nil if there is a user in the keychain. Only call this method once for each instance of your app!
	/// Only call this method on the main thread.
	///
	/// - parameter appKey: The app key to initialize the client with.
	public static func setUp(withAppKey appKey: String) {
		guard self.appKey == nil else {
			assertionFailure("PCloud client has already been set up")
			return
		}
		
		self.appKey = appKey
		
		if let user = OAuth.getAnyUser() {
			let serverRegion = APIServerRegion(rawValue: user.serverRegionId) ?? .unitedStates
			initializeClient(accessToken: user.token, serverRegion: serverRegion)
		} else if let accessToken = OAuth.getAnyToken() {
			initializeClient(accessToken: accessToken, serverRegion: .unitedStates)
		}
	}
	
	/// Creates a client object and sets it to the `sharedClient` property. Only call this method on the main thread.
	///
	/// - parameter accessToken: The access token to initialize the client with.
	public static func initializeClient(accessToken: String, serverRegion: APIServerRegion) {
		guard sharedClient == nil else {
			assertionFailure("Attempting to initialize the global PCloudClient instance, but there already is a global instance.")
			return
		}
		
		sharedClient = createClient(withAccessToken: accessToken, serverRegion: serverRegion)
	}
	
	/// Releases the `sharedClient`. You may call `initializeClient()` again after calling this method. Only call this method on the main thread.
	public static func clearClient() {
		sharedClient = nil
	}
	
	/// Clears the global pCloud client and deletes all tokens. Only call this method on the main thread.
	public static func unlinkAllUsers() {
		clearClient()
		OAuth.deleteAllTokens()
	}
	
	/// Creates a pCloud client. Does not update the `sharedClient` property. Use if you want to more directly control the lifetime of the
	/// `PCloudClient` object. Multiple clients can exist simultaneously.
	///
	/// - parameter accessToken: An OAuth access token.
	/// - parameter apiHostName: Host name of the API server to connect to.
	/// - returns: An instance of a pCloud client using the access token to authenticate network calls.
	public static func createClient(withAccessToken accessToken: String, serverRegion: APIServerRegion) -> PCloudClient {
		return createClient(withAccessToken: accessToken, apiHostName: apiHostName(for: serverRegion))
	}
	
	// Starts an authorization flow and initializes the global client on success.
	static func authorize(view: OAuthAuthorizationFlowView, completionBlock: @escaping (OAuth.Result) -> Void) {
		guard let appKey = self.appKey else {
			assertionFailure("Please set up client by calling PCloud.setUp(withAppKey: <YOUR_APP_KEY>)")
			return
		}
		
		OAuth.performAuthorizationFlow(view: view, appKey: appKey) { result in
			if case let .success(user) = result {
				OAuth.store(user)
				self.initializeClient(accessToken: user.token, serverRegion: APIServerRegion(rawValue: user.serverRegionId) ?? .unitedStates)
			}
			
			completionBlock(result)
		}
	}
	
	private static func createClient(withAccessToken accessToken: String, apiHostName: String) -> PCloudClient {
		let authenticator = OAuthAccessTokenBasedAuthenticator(accessToken: accessToken)
		let eventHub = URLSessionEventHub()
		let session = URLSession(configuration: .default, delegate: eventHub, delegateQueue: nil)
		let callOperationBuilder = URLSessionBasedNetworkOperationUtilities.createCallOperationBuilder(scheme: .https,
																									   session: session,
																									   delegate: eventHub)
		
		let uploadOperationBuilder = URLSessionBasedNetworkOperationUtilities.createUploadOperationBuilder(scheme: .https,
																										   session: session,
																										   delegate: eventHub)
		
		let downloadOperationBuilder = URLSessionBasedNetworkOperationUtilities.createDownloadOperationBuilder(session: session, delegate: eventHub)
		
		let callTaskBuilder = PCloudAPICallTaskBuilder(hostProvider: apiHostName,
													   authenticator: authenticator,
													   operationBuilder: callOperationBuilder)
		
		let uploadTaskBuilder = PCloudAPIUploadTaskBuilder(hostProvider: apiHostName,
														   authenticator: authenticator,
														   operationBuilder: uploadOperationBuilder)
		
		let downloadTaskBuilder = PCloudAPIDownloadTaskBuilder(hostProvider: apiHostName,
															   authenticator: authenticator,
															   operationBuilder: downloadOperationBuilder)
		
		return PCloudClient(callTaskBuilder: callTaskBuilder, uploadTaskBuilder: uploadTaskBuilder, downloadTaskBuilder: downloadTaskBuilder)
	}
	
	private static func apiHostName(for region: APIServerRegion) -> String {
		switch region {
		case .unitedStates: return "api.pcloud.com"
		case .europe: return "eapi.pcloud.com"
		}
	}
}
