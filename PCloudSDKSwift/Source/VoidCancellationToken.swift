//
//  VoidCancellationToken.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// An implementation of `Cancellable` that does nothing.
public struct VoidCancellationToken: Cancellable {
	public init() {}
	
	public var isCancelled: Bool {
		return false
	}
	
	public func cancel() {
		
	}
}
