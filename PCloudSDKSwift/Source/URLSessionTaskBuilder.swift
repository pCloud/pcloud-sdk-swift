//
//  URLSessionTaskBuilder.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// A URL scheme.
public enum Scheme: String {
	case http = "http"
	case https = "https"
}

public struct URLSessionTaskBuilder {
	/// Creates a `URLSessionDataTask` using a `URLSession` given a `Call.Request`.
	public static func createDataTask(request: Call.Request, session: URLSession, scheme: Scheme) -> URLSessionDataTask {
		// Build the URL.
		let url = self.url(scheme: scheme.rawValue, host: request.hostName, commandName: request.command.name)
		// Build a form data encoded query.
		let query = self.query(from: request.command.parameters, addingPercentEncoding: true)
		
		// Build a POST request.
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = HTTPMethod.post
		urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		urlRequest.httpBody = query.data(using: .utf8, allowLossyConversion: false)
		
		if let timeoutInterval = request.timeoutInterval {
			urlRequest.timeoutInterval = timeoutInterval
		}
		
		return session.dataTask(with: urlRequest)
	}
	
	/// Creates a `URLSessionUploadTask` using a `URLSession` given an `Upload.Request`.
	public static func createUploadTask(request: Upload.Request, session: URLSession, scheme: Scheme) -> URLSessionUploadTask {
		// Build a GET query.
		let query = self.query(from: request.command.parameters, addingPercentEncoding: false)
		// Build the URL.
		let url = self.url(scheme: scheme.rawValue, host: request.hostName, commandName: request.command.name, query: query)
		
		// Build a POST request.
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = HTTPMethod.post
		urlRequest.setValue("applicaton/octet-stream", forHTTPHeaderField: "Content-Type")
		
		if let timeoutInterval = request.timeoutInterval {
			urlRequest.timeoutInterval = timeoutInterval
		}
		
		switch request.body {
		case .file(let url): return session.uploadTask(with: urlRequest, fromFile: url)
		case .data(let data): return session.uploadTask(with: urlRequest, from: data)
		}
	}
	
	/// Creates a `URLSessionDownloadTask` using a `URLSession` given a `Download.Request`.
	public static func createDownloadTask(request: Download.Request, session: URLSession) -> URLSessionDownloadTask {
		var urlRequest = URLRequest(url: request.resourceAddress)
		
		if let timeoutInterval = request.timeoutInterval {
			urlRequest.timeoutInterval = timeoutInterval
		}
		
		for (name, value) in buildHTTPHeaderFields(cookiesDictionary: request.cookies, resourceAddress: request.resourceAddress) {
			urlRequest.addValue(value, forHTTPHeaderField: name)
		}
		
		return session.downloadTask(with: urlRequest)
	}
	
	public static func buildHTTPHeaderFields(cookiesDictionary: [String: String], resourceAddress: URL) -> [String: String] {
		guard let host = resourceAddress.host else {
			return [:]
		}
		
		let path = resourceAddress.path
		
		let cookies = cookiesDictionary.flatMap { name, value in
			HTTPCookie(properties: [.name: name, .value: value, .domain: host, .path: path])
		}
		
		return HTTPCookie.requestHeaderFields(with: cookies)
	}
	
	// Functions for encoding command parameter values to percent encoded strings.
	
	public static func encode(_ value: String) -> String {
		return value.addingPercentEncoding(withAllowedCharacters: .urlQueryParameterAllowedCharacterSetRFC3986())!
	}
	
	public static func encode(_ value: Bool) -> String {
		return value ? "1" : "0"
	}
	
	public static func encode(_ value: UInt64) -> String {
		return "\(value)"
	}
	
	
	// Functions for building a query string from command parameters.
	
	public static func rawQueryComponent(from parameter: Call.Command.Parameter) -> String {
		switch parameter {
		case let .boolean(name, value): return "\(name)=\(encode(value))"
		case let .number(name, value): return "\(name)=\(encode(value))"
		case let .string(name, value): return "\(name)=\(value)"
		}
	}
	
	public static func percentEncodedQueryComponent(from parameter: Call.Command.Parameter) -> String {
		switch parameter {
		case let .boolean(name, value): return "\(encode(name))=\(encode(value))"
		case let .number(name, value): return "\(encode(name))=\(encode(value))"
		case let .string(name, value): return "\(encode(name))=\(encode(value))"
		}
	}
	
	public static func query(from parameters: [Call.Command.Parameter], addingPercentEncoding encode: Bool) -> String {
		let components: [String]
		
		if encode {
			components = parameters.map(percentEncodedQueryComponent)
		} else {
			components = parameters.map(rawQueryComponent)
		}
		
		return components.joined(separator: "&")
	}
	
	public static func url(scheme: String, host: String, commandName: String, query: String? = nil) -> URL {
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

public extension CharacterSet {
	// A character with characters allowed in a URL query as per RFC 3986.
	static func urlQueryParameterAllowedCharacterSetRFC3986() -> CharacterSet {
		return self.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
	}
}
