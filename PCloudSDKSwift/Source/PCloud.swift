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
	/// A global client instance. Automatically initialized either inside `setup()` or `authorize()`.
	private(set) public static var sharedClient: PCloudClient?
	
	/// The app key provided in `setup()`.
	private(set) public static var appKey: String?
	
	/// Attempts to initialize a pCloud client instance by checking for an existing user in the keychain.
	/// The `sharedClient` property will be non-nil if there is a user in the keychain. Only call this method once for each instance of your app!
	/// This method is not thread-safe. Only call
	///
	/// - parameter appKey: The app key to initialize the client with.
	public static func setup(appKey: String) {
		precondition(self.appKey == nil, "PCloud client has already been set up")
		self.appKey = appKey
		
		if let accessToken = OAuth.getAnyToken() {
			initializeClient(accessToken: accessToken)
		}
	}
	
	/// Creates a client object and sets it to the `sharedClient` property.
	///
	/// - parameter accessToken: The access token to initialize the client with.
	public static func initializeClient(accessToken: String) {
		guard sharedClient == nil else {
			assertionFailure("Attempting to initialize the global PCloudClient instance, but there already is a global instance.")
			return
		}
		
		sharedClient = createClient(accessToken: accessToken)
	}
	
	/// Releases the `sharedClient`. After this call, you may call
	public static func clearClient() {
		sharedClient = nil
	}
	
	public static func createClient(accessToken: String) -> PCloudClient {
		return createClient(withAccessToken: accessToken, serverRegion: .unitedStates)
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
