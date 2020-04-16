//
//  Keychain.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// A simple wrapper around the keychain C API.
public struct Keychain {
	/// Fetches and returns data for a key.
	///
	/// - parameter key: The key to check against.
	/// - returns: The data found against `key`, or `nil` if no entry was found for `key`.
	public static func getData(forKey key: String) -> Data? {
		let query = self.query(attributes: [
			kSecAttrAccount as String: key,
			kSecReturnData as String: kCFBooleanTrue,
			kSecMatchLimit as String: kSecMatchLimitOne
		])
		
		var data: AnyObject?
		
		let result = withUnsafeMutablePointer(to: &data) {
			return SecItemCopyMatching(query, $0)
		}
		
		guard result == noErr else {
			return nil
		}
		
		return data as! Data?
	}
	
	/// Stores a data buffer.
	///
	/// - parameter value: The data to store.
	/// - parameter key: The key to store `value` against.
	/// - returns: Whether the operation was successful.
	@discardableResult public static func set(_ value: Data, forKey key: String) -> Bool {
		let query = self.query(attributes: [
			kSecAttrAccount as String: key,
			kSecValueData as String: value
		])
		
		_ = deleteData(forKey: key)
		
		return SecItemAdd(query, nil) == noErr
	}
	
	/// Deletes an entry.
	///
	/// - parameter key: The key identifying the entry to remove.
	/// - returns: Whether the operation was successful.
	@discardableResult public static func deleteData(forKey key: String) -> Bool {
		let query = self.query(attributes: [kSecAttrAccount as String: key])
		return SecItemDelete(query) == noErr
	}
	
	/// Fetches and returns all keys stored in the namespace defined by an instance of this keychain.
	///
	/// - returns: An array of all keys stored in the namespace defined by an instance of this keychain or an empty array on error.
	public static func getAllKeys() -> [String] {
		let query = self.query(attributes: [
			kSecReturnAttributes as String: kCFBooleanTrue,
			kSecMatchLimit as String: kSecMatchLimitAll
		])
		
		var data: AnyObject?
		
		let result = withUnsafeMutablePointer(to: &data) {
			return SecItemCopyMatching(query, $0)
		}
		
		guard result == noErr else {
			return []
		}
		
		let dictionary = data as! [[String: AnyObject]]? ?? []
		return dictionary.map { $0[kSecAttrAccount as String] as! String }
	}
	
	private static func query(attributes: [String: Any]) -> CFDictionary {
		var copy = attributes
		
		copy[kSecAttrService as String] = "\(Bundle.main.bundleIdentifier ?? "").pcloud"
		copy[kSecClass as String] = kSecClassGenericPassword
		
		return copy as CFDictionary
	}
}


// Utility methods for fetching and storing different types of data in the keychain.
extension Keychain {
	/// Stores a string by converting it to data using UTF8 encoding.
	///
	/// - parameter value: The string to store.
	/// - parameter key: The key to store `value` against.
	/// - returns: Whether the operation was successful.
	@discardableResult public static func set(_ value: String, forKey key: String) -> Bool {
		if let data = value.data(using: .utf8) {
			return set(data, forKey: key)
		}
		
		return false
	}
	
	/// Fetches data, parses it as a UTF8 string and returns the resulting string.
	///
	/// - parameter key: The key to check against.
	/// - returns: The data against `key` as a UTF8 string.
	public static func getString(forKey key: String) -> String? {
		if let data = getData(forKey: key) {
			return String(data: data, encoding: .utf8)
		}
		
		return nil
	}
}
