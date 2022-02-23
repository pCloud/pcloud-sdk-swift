//
//  CallError.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// An error combining API and network layer errors.
public enum CallError<MethodError>: Error {
	case authError(PCloudAPI.AuthError)
	case permissionError(PCloudAPI.PermissionError)
	case badInputError(Int, String?)
	case rateLimitError
	case methodError(MethodError)
	case serverInternalError(Int, String?)
	case otherAPIError(Int, String?)
	case clientError(Error)
	case protocolError(Error)
}


extension CallError where MethodError: RawRepresentable, MethodError.RawValue == Int {
	/// Initializes an instance of a `CallError` with an API error.
	public init(apiError: PCloudAPI.Error<MethodError>) {
		switch apiError {
		case .authError(let authError):
			self = .authError(authError)
			
		case .permissionError(let permissionError):
			self = .permissionError(permissionError)
			
		case let .badInputError(code, message):
			self = .badInputError(code, message)
			
		case .methodError(let error):
			self = .methodError(error)
			
		case .rateLimitError:
			self = .rateLimitError
			
		case let .serverInternalError(code, message):
			self = .serverInternalError(code, message)
			
		case let .other(code, message):
			self = .otherAPIError(code, message)
		}
	}
}
