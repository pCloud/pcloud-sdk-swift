//
//  Authenticator.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Authenticates a `Call.Command`.
public protocol Authenticator {
	/// Parameters containing authentication information for a `Call.Command`.
	var authenticationParameters: [Call.Command.Parameter] { get }
}
