//
//  Lock.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import Darwin

/// A non-recursive implementation of a mutex. Coordinates the operation of multiple threads of execution.
public final class Lock {
	// The underlying mutex.
	private var mutex = pthread_mutex_t()
	
	deinit {
		let result = pthread_mutex_destroy(&mutex)
		assert(result == 0)
	}
	
	/// Initializes a new instance.
	public init() {
		pthread_mutex_init(&mutex, nil)
	}
	
	/// Locks this mutex.
	public func lock() {
		let result = pthread_mutex_lock(&mutex)
		assert(result == 0)
	}
	
	/// Unlocks this mutex.
	public func unlock() {
		let result = pthread_mutex_unlock(&mutex)
		assert(result == 0)
	}
}

extension Lock {
	/// Executes a block inside a lock/unlock transaction.
	///
	/// - parameter block: A block to execute.
	/// - returns: The value returned by the block (if any).
	/// - throws: The error thrown by the block (if any).
	public func inCriticalScope<T>(_ block: () throws -> T) rethrows -> T {
		lock()
		defer { unlock() }
		return try block()
	}
}
