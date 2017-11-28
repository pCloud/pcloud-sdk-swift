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
public extension Dictionary where Key == String, Value == Any {
	
	/// Accesses the value associated with a given key, forcefully casts it to this function's return value and returns it.
	///
	/// - parameter key: A key for the value.
	/// - returns: The value cast to T, or `nil` if nothing is mapped against `key`.
	func value<T>(_ key: String) -> T? { return self[key] as! T? }
	
	func intOrNil(_ key: String) -> Int? { return value(key) }
	func boolOrNil(_ key: String) -> Bool? { return value(key) }
	func stringOrNil(_ key: String) -> String? { return value(key) }
	
	func floatOrNil(_ key: String) -> Float? {
		guard let value = self[key] else { return nil }
		
		// A float might be parsed as an NSNumber by the JSON parser.
		if let value = value as? NSNumber {
			return value.floatValue
		}
		
		return (value as! Float)
		
	}
	
	func uintOrNil(_ key: String) -> UInt? { return value(key) }
	func uint32OrNil(_ key: String) -> UInt32? { return value(key) }
	
	func uint64OrNil(_ key: String) -> UInt64? {
		guard let value = self[key] else { return nil }
		
		// A uint64 may be parsed as an NSNumber by the JSON parser.
		if let value = value as? NSNumber {
			return value.uint64Value
		}
		
		return (value as! UInt64)
	}
	
	func numberOrNil(_ key: String) -> NSNumber? { return value(key) }
	func dictionaryOrNil(_ key: String) -> [String: Any]? { return value(key) }
	
	
	
	func int(_ key: String) -> Int { return value(key)! }
	func bool(_ key: String) -> Bool { return value(key)! }
	func string(_ key: String) -> String { return value(key)! }
	func float(_ key: String) -> Float { return floatOrNil(key)! }
	func uint(_ key: String) -> UInt { return value(key)! }
	func uint32(_ key: String) -> UInt32 { return value(key)! }
	func uint64(_ key: String) -> UInt64 { return uint64OrNil(key)! }
	func number(_ key: String) -> NSNumber { return value(key)! }
	func dictionary(_ key: String) -> [String: Any] { return value(key)! }
}
