//
//  Result.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// The result of a task that can either succeed or fail. The task produces a value on successful completion or an error on failure.
public enum Result<T, E> {
	/// The task has completed successfully.
	case success(T)
	/// The task has failed.
	case failure(E)
}

public extension Result {
	/// `true` when this instance represents a success, `false` otherwise.
	var isSuccess: Bool {
		if case .success(_) = self {
			return true
		}
		
		return false
	}
	
	/// `true` when this instance represents a failure, `false` otherwise.
	var isFailure: Bool {
		return !isSuccess
	}
	
	/// The associated value if this instance represents a success, `nil` otherwise.
	var payload: T? {
		if case .success(let payload) = self {
			return payload
		}
		
		return nil
	}
	
	/// The associated error if this instance represents a failure, `nil` otherwise.
	var error: E? {
		if case .failure(let error) = self {
			return error
		}
		
		return nil
	}
}

public extension Result {
	/// If `.success`, replaces the payload in this instance with the one returned by the `transform` block,
	/// otherwise does nothing.
	func replacingPayload<U>(_ transform: (T) throws -> U) rethrows -> Result<U, E> {
		switch self {
		case .success(let payload): return .success(try transform(payload))
		case .failure(let error): return .failure(error)
		}
	}
	
	/// If `.failure`, replaces the error in this instance with the one returned by the `transform` block,
	/// otherwise does nothing.
	func replacingError<U>(_ transform: (E) throws -> U) rethrows -> Result<T, U> {
		switch self {
		case .success(let payload): return .success(payload)
		case .failure(let error): return .failure(try transform(error))
		}
	}
}

extension Result: CustomStringConvertible {
	public var description: String {
		switch self {
		case .success(let payload): return "SUCCESS: \(payload)"
		case .failure(let error): return "FAILURE: \(error)"
		}
	}
}
