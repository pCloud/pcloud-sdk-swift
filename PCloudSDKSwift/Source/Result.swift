//
//  Result.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// The result of a task that can either succeed or fail. The task produces a value on successful completion or an error on failure.
public enum Result<T, E> {
	/// The task has completed successfully.
	case success(T)
	/// The task has failed.
	case failure(E)
}

extension Result {
	/// `true` when this instance represents a success, `false` otherwise.
	public var isSuccess: Bool {
		if case .success(_) = self {
			return true
		}
		
		return false
	}
	
	/// `true` when this instance represents a failure, `false` otherwise.
	public var isFailure: Bool {
		return !isSuccess
	}
	
	/// The associated value if this instance represents a success, `nil` otherwise.
	public var payload: T? {
		if case .success(let payload) = self {
			return payload
		}
		
		return nil
	}
	
	/// The associated error if this instance represents a failure, `nil` otherwise.
	public var error: E? {
		if case .failure(let error) = self {
			return error
		}
		
		return nil
	}
}

extension Result {
	public func map<T2>(_ transform: (T) throws -> T2) rethrows -> Result<T2, E> {
		switch self {
		case .success(let payload): return .success(try transform(payload))
		case .failure(let error): return .failure(error)
		}
	}
	
	public func mapError<E2>(_ transform: (E) throws -> E2) rethrows -> Result<T, E2> {
		switch self {
		case .success(let payload): return .success(payload)
		case .failure(let error): return .failure(try transform(error))
		}
	}
	
	public func flatMap<T2>(_ transform: (T) throws -> Result<T2, E>) rethrows -> Result<T2, E> {
		switch self {
		case .success(let payload): return try transform(payload)
		case .failure(let error): return .failure(error)
		}
	}
	
	public func flatMapError<E2>(_ transform: (E) throws -> Result<T, E2>) rethrows -> Result<T, E2> {
		switch self {
		case .success(let payload): return .success(payload)
		case .failure(let error): return try transform(error)
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

extension Result: Equatable where T: Equatable, E: Equatable {
}
