//
//  OAuthAccessTokenBasedAuthenticator.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Concrete implementation of `Authenticator` using an OAuth2 access token.
public struct OAuthAccessTokenBasedAuthenticator {
	private let accessToken: String
	
	/// Initializes a new authenticator with an access token.
	///
	/// - parameter accessToken: An OAuth2 access token.
	public init(accessToken: String) {
		self.accessToken = accessToken
	}
}

extension OAuthAccessTokenBasedAuthenticator: Authenticator {
	public var authenticationParameters: [Call.Command.Parameter] {
		return [.string(name: "access_token", value: accessToken)]
	}
}
