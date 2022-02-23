//
//  HostProvider.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Provides pCloud API host names.
public protocol HostProvider {
	/// The current default pCloud API host name.
	var defaultHostName: String { get }
}

extension String: HostProvider {
	public var defaultHostName: String {
		return self
	}
}
