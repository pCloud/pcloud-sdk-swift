//
//  PCloud.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Convenience static class providing a global `PCloudClient` instance.
public final class PCloud {
	/// A global client instance. Automatically initialized either inside `setup()` or `authorize()`.
	private(set) public static var sharedClient: PCloudClient?
	
	/// The app key provided in `setup()`.
	private(set) public static var appKey: String?
	
	/// Attempts to initialize a pCloud client instance by checking for an existing access token in the keychain.
	///
	/// - parameter appKey: The app key to initialize the client with.
	public static func setup(appKey: String) {
		precondition(self.appKey == nil, "PCloud client has already been set up")
		self.appKey = appKey
		
		if let accessToken = OAuth.getAnyToken() {
			initializeClient(accessToken: accessToken)
		}
	}
	
	/// Initializes the global pCloud client instance.
	///
	/// - parameter accessToken: The access token to initialize the client with.
	public static func initializeClient(accessToken: String) {
		sharedClient = createClient(accessToken: accessToken)
	}
	
	/// Sets the global pCloud client instance to `nil`.
	public static func clearClient() {
		sharedClient = nil
	}
	
	/// Creates a pCloud client with an access token.
	///
	/// - parameter accessToken: An OAuth access token.
	/// - returns: An instance of a pCloud client using the access token to authenticate network calls.
	public static func createClient(accessToken: String) -> PCloudClient {
		let authenticator = OAuthAccessTokenBasedAuthenticator(accessToken: accessToken)
		let eventHub = URLSessionEventHub()
		let session = URLSession(configuration: .default, delegate: eventHub, delegateQueue: nil)
		let callDispatcher = URLSessionBasedNetworkOperationUtilities.createCallOperationBuilder(scheme: .https, session: session, delegate: eventHub)
		let uploadDispatcher = URLSessionBasedNetworkOperationUtilities.createUploadOperationBuilder(scheme: .https, session: session, delegate: eventHub)
		let downloadDispatcher = URLSessionBasedNetworkOperationUtilities.createDownloadOperationBuilder(session: session, delegate: eventHub)
		
		return PCloudClient(controller: APITaskController(hostProvider: "api.pcloud.com",
		                                                  authenticator: authenticator,
		                                                  callDispatcher: callDispatcher,
		                                                  uploadDispatcher: uploadDispatcher,
		                                                  downloadDispatcher: downloadDispatcher))
	}
	
	/// Clears the global pCloud client and deletes all tokens.
	public static func unlinkAllUsers() {
		clearClient()
		OAuth.deleteAllTokens()
	}
	
	// Starts an authorization flow and initializes the global client on success.
	static func authorize(view: OAuthAuthorizationFlowView, completionBlock: @escaping (OAuth.Result) -> Void) {
		guard let appKey = self.appKey else {
			preconditionFailure("Please set up client by calling PCloud.setup(appKey: <YOUR_APP_KEY>)")
		}
		
		OAuth.performAuthorizationFlow(view: view, appKey: appKey, storeToken: OAuth.storeToken) { result in
			if case .success(let token, _) = result {
				self.initializeClient(accessToken: token)
			}
			
			completionBlock(result)
		}
	}
}
