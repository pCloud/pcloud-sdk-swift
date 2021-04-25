//
//  Cancellable.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// A disposable resource.
public protocol Cancellable {
	/// `true` if this resource has been disposed of, `false` otherwise.
	var isCancelled: Bool { get }
	
	/// Disposes of this resource.
	func cancel()
}
