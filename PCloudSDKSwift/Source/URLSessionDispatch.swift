//
//  URLSessionDispatch.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// A URL scheme.
public enum Scheme: String {
	case http = "http"
	case https = "https"
}

/// Contains logic for building `URLSessionTask`-backed network operations from network requests.
public struct URLSessionDispatch {
	/// Creates and returns a block that builds a `CallOperation` from a `Call.Request` using a `URLSession`.
	///
	/// - parameter scheme: A scheme to use when building the operation.
	/// - parameter session: A session used to create data tasks.
	/// - parameter delegate: The session delegate.
	/// - returns: A block that builds a `URLSessionDataTask`-backed `CallOperation` from a `Call.Request`.
	public static func callOperationBuilder(scheme: Scheme, session: URLSession, delegate: URLSessionEventHub) -> (Call.Request) -> CallOperation {
		return { request in
			// Build the URL.
			let url = self.url(scheme: scheme.rawValue, host: request.hostName, commandName: request.command.name)
			// Build a form data encoded query.
			let query = self.query(from: request.command.parameters, addingPercentEncoding: true)
			
			// Build a POST request.
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = HTTPMethod.post
			urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
			urlRequest.httpBody = query.data(using: .utf8, allowLossyConversion: false)
			
			// Build the operation and assign it as observer to the data task.
			let task = session.dataTask(with: urlRequest)
			let operation = URLSessionBasedCallOperation(task: task)
			delegate.setObserver(operation, for: task)
			
			return operation
		}
	}
	
	/// Creates and returns a block that builds an `UploadOperation` from an `Upload.Request` using a `URLSession`.
	///
	/// - parameter scheme: A scheme to use when building the operation.
	/// - parameter session: A session used to create upload tasks.
	/// - parameter delegate: The session delegate.
	/// - returns: A block that builds a `URLSessionUploadTask`-backed `UploadOperation` from an `Upload.Request`.
	public static func uploadOperationBuilder(scheme: Scheme, session: URLSession, delegate: URLSessionEventHub) -> (Upload.Request) -> UploadOperation {
		return { request in
			// Build a GET query.
			let query = self.query(from: request.command.parameters, addingPercentEncoding: false)
			// Build the URL.
			let url = self.url(scheme: scheme.rawValue, host: request.hostName, commandName: request.command.name, query: query)
			
			// Build a POST request.
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = HTTPMethod.post
			urlRequest.setValue("applicaton/octet-stream", forHTTPHeaderField: "Content-Type")
			
			// Build the operation and assign it as observer to the upload task.
			let task: URLSessionUploadTask
			
			switch request.body {
			case .file(let url): task = session.uploadTask(with: urlRequest, fromFile: url)
			case .data(let data): task = session.uploadTask(with: urlRequest, from: data)
			}
			
			let operation = URLSessionBasedUploadOperation(task: task)
			delegate.setObserver(operation, for: task)
			
			return operation
		}
	}
	
	public static func downloadOperationBuilder(session: URLSession, delegate: URLSessionEventHub) -> (Download.Request) -> DownloadOperation {
		return { request in
			// Build the operation and assign it as observer to the upload task.
			let task = session.downloadTask(with: request.resourceAddress)
			let operation = URLSessionBasedDownloadOperation(task: task, destination: request.destination)
			delegate.setObserver(operation, for: task)
			
			return operation
		}
	}
	
	
	// Functions for encoding command parameter values to percent encoded strings.
	
	static func encode(_ value: String) -> String {
		return value.addingPercentEncoding(withAllowedCharacters: .urlQueryParameterAllowedCharacterSetRFC3986())!
	}
	
	static func encode(_ value: Bool) -> String {
		return value ? "1" : "0"
	}
	
	static func encode(_ value: UInt64) -> String {
		return "\(value)"
	}
	
	
	// Functions for building a query string from command parameters.
	
	static func rawQueryComponent(from parameter: Call.Command.Parameter) -> String {
		switch parameter {
		case let .boolean(name, value): return "\(name)=\(encode(value))"
		case let .number(name, value): return "\(name)=\(encode(value))"
		case let .string(name, value): return "\(name)=\(value)"
		}
	}
	
	static func percentEncodedQueryComponent(from parameter: Call.Command.Parameter) -> String {
		switch parameter {
		case let .boolean(name, value): return "\(encode(name))=\(encode(value))"
		case let .number(name, value): return "\(encode(name))=\(encode(value))"
		case let .string(name, value): return "\(encode(name))=\(encode(value))"
		}
	}
	
	static func query(from parameters: [Call.Command.Parameter], addingPercentEncoding encode: Bool) -> String {
		let components: [String]
		
		if encode {
			components = parameters.map(percentEncodedQueryComponent)
		} else {
			components = parameters.map(rawQueryComponent)
		}
		
		return components.joined(separator: "&")
	}
	
	static func url(scheme: String, host: String, commandName: String, query: String? = nil) -> URL {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = "/\(commandName)"
		components.query = query
		
		return components.url!
	}
}

struct HTTPMethod {
	static let get = "GET"
	static let post = "POST"
	static let put = "PUT"
}

extension CharacterSet {
	// A character with characters allowed in a URL query as per RFC 3986.
	static func urlQueryParameterAllowedCharacterSetRFC3986() -> CharacterSet {
		return self.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
	}
}
