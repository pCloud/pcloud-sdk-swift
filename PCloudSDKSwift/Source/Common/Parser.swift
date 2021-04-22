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
	public func value<T>(_ key: String) -> T? { return self[key] as! T? }
	
	public func intOrNil(_ key: String) -> Int? { return value(key) }
	public func boolOrNil(_ key: String) -> Bool? { return value(key) }
	public func stringOrNil(_ key: String) -> String? { return value(key) }
	
	public func floatOrNil(_ key: String) -> Float? {
		guard let value = self[key] else { return nil }
		
		// A float might be parsed as an NSNumber by the JSON parser.
		if let value = value as? NSNumber {
			return value.floatValue
		}
		
		return (value as! Float)
		
	}
	
	public func uintOrNil(_ key: String) -> UInt? { return value(key) }
	public func uint32OrNil(_ key: String) -> UInt32? { return value(key) }
	
	public func uint64OrNil(_ key: String) -> UInt64? {
		guard let value = self[key] else { return nil }
		
		// A uint64 may be parsed as an NSNumber by the JSON parser.
		if let value = value as? NSNumber {
			return value.uint64Value
		}
		
		return (value as! UInt64)
	}
	
	public func numberOrNil(_ key: String) -> NSNumber? { return value(key) }
	public func dictionaryOrNil(_ key: String) -> [String: Any]? { return value(key) }
	
	
	
	public func int(_ key: String) -> Int { return value(key)! }
	public func bool(_ key: String) -> Bool { return value(key)! }
	public func string(_ key: String) -> String { return value(key)! }
	public func float(_ key: String) -> Float { return floatOrNil(key)! }
	public func uint(_ key: String) -> UInt { return value(key)! }
	public func uint32(_ key: String) -> UInt32 { return value(key)! }
	public func uint64(_ key: String) -> UInt64 { return uint64OrNil(key)! }
	public func number(_ key: String) -> NSNumber { return value(key)! }
	public func dictionary(_ key: String) -> [String: Any] { return value(key)! }
}
