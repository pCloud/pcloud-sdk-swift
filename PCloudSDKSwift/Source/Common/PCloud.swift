//
//  PCloud.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import AuthenticationServices

/// Convenience namespace for the SDK. Hosts a global `PCloudClient` instance.
public enum PCloud {
	/// A global client instance. Automatically initialized either inside `setUp()` or `authorize()`.
	/// Access on the main thread only.
	private(set) public static var sharedClient: PCloudClient?
	
	/// The app key provided in `setUp()`.
	private(set) public static var appKey: String?
	
	/// Stores the app key and attempts to initialize a pCloud client instance by checking for an existing user in the keychain.
	/// The app key is used for the OAuth authorization flow.
	/// Generally you should always call this method sometime during app launch. You don't need to call it if you do not intend to use the OAuth
	/// authorization methods provided in this namespace.
	/// After this method returns, the `sharedClient` property will be non-nil if there is a user in the keychain.
	/// Only call this method once for each instance of your app and only on the main thread.
	///
	/// - parameter appKey: The app key to initialize the client with.
	public static func setUp(withAppKey appKey: String) {
		guard self.appKey == nil else {
			assertionFailure("PCloud client has already been set up")
			return
		}
		
		self.appKey = appKey
		
		if let user = OAuth.getAnyUser() {
			initializeSharedClient(with: user)
		}
	}
	
	/// Creates a client object and sets it to the `sharedClient` property. Only call this method on the main thread.
	/// Will do nothing if the shared client is already initialized.
	///
	/// - parameter user: A `OAuth.User` value obtained from the keychain or from the OAuth flow.
	public static func initializeSharedClient(with user: OAuth.User) {
		guard sharedClient == nil else {
			assertionFailure("Attempting to initialize the global PCloudClient instance, but there already is a global instance.")
			return
		}
		
		sharedClient = createClient(with: user)
	}
	
	/// Releases the `sharedClient`. You may call `initializeSharedClient()` again after calling this method.
	/// Note that this will not stop any running / pending tasks you've created using the client. Only call this method on the main thread.
	public static func clearSharedClient() {
		sharedClient = nil
	}
	
	/// Releases the `sharedClient` and deletes all user data in the keychain. You may call `initializeSharedClient()` again after calling
	/// this method. Note that this will not stop any running / pending tasks you've created using the client.
	/// Only call this method on the main thread.
	public static func unlinkAllUsers() {
		clearSharedClient()
		OAuth.deleteAllUsers()
	}
	
	/// Creates a pCloud client. Does not update the `sharedClient` property. You are responsible for storing it and keeping it alive. Use if
	/// you want a more direct control over the lifetime of the `PCloudClient` object. Multiple clients can exist simultaneously.
	///
	/// - parameter user: A `OAuth.User` value obtained from the keychain or the OAuth flow.
	/// - returns: An instance of a `PCloudClient` ready to take requests.
	public static func createClient(with user: OAuth.User) -> PCloudClient {
		return createClient(withAccessToken: user.token, apiHostName: user.httpAPIHostName)
	}
	
	@available(iOS 13, OSX 10.15, *)
	static func authorize(with anchor: ASPresentationAnchor, completionBlock: @escaping (OAuth.Result) -> Void) {
		guard let appKey = self.appKey else {
			assertionFailure("Please set up client by calling PCloud.setUp(withAppKey: <YOUR_APP_KEY>) before attempting to authorize using OAuth")
			return
		}
		
		OAuth.performAuthorizationFlow(with: anchor, appKey: appKey) { result in
			self.handleAuthorizationFlowResult(result)
			completionBlock(result)
		}
	}
	
	// Starts an authorization flow and initializes the global client on success.
	static func authorize(with view: OAuthAuthorizationFlowView, completionBlock: @escaping (OAuth.Result) -> Void) {
		guard let appKey = self.appKey else {
			assertionFailure("Please set up client by calling PCloud.setUp(withAppKey: <YOUR_APP_KEY>) before attempting to authorize using OAuth")
			return
		}
		
		OAuth.performAuthorizationFlow(with: view, appKey: appKey) { result in
			self.handleAuthorizationFlowResult(result)
			completionBlock(result)
		}
	}
	
	private static func handleAuthorizationFlowResult(_ result: OAuth.Result) {
		if case let .success(user) = result {
			OAuth.store(user)
			self.initializeSharedClient(with: user)
		}
	}
	
	private static func createClient(withAccessToken accessToken: String, apiHostName: String) -> PCloudClient {
		let authenticator = OAuthAccessTokenBasedAuthenticator(accessToken: accessToken)
		let eventHub = URLSessionEventHub()
		let session = URLSession(configuration: .default, delegate: eventHub, delegateQueue: nil)
		
		// The event hub is expected to be kept in memory by the operation builder blocks.
		
		let callOperationBuilder = URLSessionBasedNetworkOperationUtilities.createCallOperationBuilder(with: .https,
																									   session: session,
																									   delegate: eventHub)
		
		let uploadOperationBuilder = URLSessionBasedNetworkOperationUtilities.createUploadOperationBuilder(with: .https,
																										   session: session,
																										   delegate: eventHub)
		
		let downloadOperationBuilder = URLSessionBasedNetworkOperationUtilities.createDownloadOperationBuilder(with: session, delegate: eventHub)
		
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
}
