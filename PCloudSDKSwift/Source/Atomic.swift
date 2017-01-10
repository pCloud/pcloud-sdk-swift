//
//  Atomic.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// An object providing atomic access to an underlying value.
public class Atomic<T> {
	// The lock controlling access to this instance's value.
	private let lock = Lock()
	// The underlying value of this instance.
	private var resource: T
	
	/// The underlying value of this instance. Getting and setting the value is done atomically.
	public var value: T {
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
	public init(_ value: T) {
		resource = value
	}
	
	/// Atomically modifies this instance's value and returns the old one.
	///
	/// - parameter block: A block that takes the current value as the input argument and returns the modified value.
	/// - returns: The old value.
	/// - throws: The error thrown by the block (if any).
	@discardableResult
	public func modify(_ block: (T) throws -> (T)) rethrows -> T {
		return try lock.inCriticalScope {
			let oldValue = resource
			resource = try block(resource)
			return oldValue
		}
	}
}

