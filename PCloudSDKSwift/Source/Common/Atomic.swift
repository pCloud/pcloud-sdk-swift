//
//  Atomic.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// An object providing atomic access to an underlying value.
final class Atomic<T> {
	// The lock controlling access to this instance's value.
	private let lock = Lock()
	// The underlying value of this instance.
	private var resource: T
	
	/// The underlying value of this instance. Getting and setting the value is done atomically.
	var value: T {
		get {
			return lock.inCriticalScope { self.resource }
		}
		set {
			lock.inCriticalScope { self.resource = newValue }
		}
	}
	
	/// Initializes a new instance with a value.
	///
	/// - parameter value: The initial underlying value of this instance.
	init(_ value: T) {
		resource = value
	}
	
	/// Atomically modifies this instance's value and returns the value returned from the block.
	///
	/// - parameter block: A block that takes the current value as the input argument.
	/// - returns: The return value, if any, of the `block` parameter.
	/// - throws: The error thrown by the block (if any).
	@discardableResult func withValue<R>(_ block: (inout T) throws -> (R)) rethrows -> R {
		return try lock.inCriticalScope {
			return try block(&resource)
		}
	}
}

