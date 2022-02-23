//
//  Parser.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// A parser.
public protocol Parser {
	/// The type of the input data.
	associatedtype Input
	/// The type of the output data.
	associatedtype Output
	
	/// Parses input data and returns the output data or throws on error.
	///
	/// - parameter input: The data to parse.
	/// - returns: The parsed data.
	/// - throws: Implementation-specific error.
	func parse(_ input: Input) throws -> Output
}

// Utility extension around the API response dictionary, providing convenient interface for accessing typed values.
extension Dictionary where Key == String, Value == Any {
	
	/// Accesses the value associated with a given key, forcefully casts it to this function's return value and returns it.
	///
	/// - parameter key: A key for the value.
	/// - returns: The value cast to T, or `nil` if nothing is mapped against `key`.
	public func value<T>(_ key: String) -> T? { self[key] as! T? }
	
	public func intOrNil(_ key: String) -> Int? { numberOrNil(key)?.intValue }
	public func boolOrNil(_ key: String) -> Bool? { numberOrNil(key)?.boolValue }
	public func stringOrNil(_ key: String) -> String? { value(key) }
	public func floatOrNil(_ key: String) -> Float? { numberOrNil(key)?.floatValue }
	public func uintOrNil(_ key: String) -> UInt? { numberOrNil(key)?.uintValue }
	public func uint32OrNil(_ key: String) -> UInt32? { numberOrNil(key)?.uint32Value }
	public func uint64OrNil(_ key: String) -> UInt64? { numberOrNil(key)?.uint64Value }
	public func numberOrNil(_ key: String) -> NSNumber? { value(key) }
	public func dictionaryOrNil(_ key: String) -> [String: Any]? { value(key) }
	
	public func int(_ key: String) -> Int { intOrNil(key)! }
	public func bool(_ key: String) -> Bool { boolOrNil(key)! }
	public func string(_ key: String) -> String { value(key)! }
	public func float(_ key: String) -> Float { floatOrNil(key)! }
	public func uint(_ key: String) -> UInt { uintOrNil(key)! }
	public func uint32(_ key: String) -> UInt32 { uint32OrNil(key)! }
	public func uint64(_ key: String) -> UInt64 { uint64OrNil(key)! }
	public func number(_ key: String) -> NSNumber { value(key)! }
	public func dictionary(_ key: String) -> [String: Any] { value(key)! }
}
