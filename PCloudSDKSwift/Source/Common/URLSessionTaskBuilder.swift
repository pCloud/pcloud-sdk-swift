//
//  URLSessionTaskBuilder.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

public enum URLScheme: String {
	case http = "http"
	case https = "https"
}

public enum URLSessionTaskBuilder {
	/// Creates a `URLSessionDataTask` using a `URLSession` given a `Call.Request`.
	public static func createDataTask(with request: Call.Request, session: URLSession, scheme: URLScheme) -> URLSessionDataTask {
		// Build the URL.
		let url = buildURL(withScheme: scheme.rawValue, host: request.hostName, commandName: request.command.name, query: nil)
		// Build a form data encoded query.
		let query = buildQuery(with: request.command.parameters, addingPercentEncoding: true)
		
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
	public static func createUploadTask(with request: Upload.Request, session: URLSession, scheme: URLScheme) -> URLSessionUploadTask {
		// Build a GET query.
		let query = buildQuery(with: request.command.parameters, addingPercentEncoding: true)
		// Build the URL.
		let url = buildURL(withScheme: scheme.rawValue, host: request.hostName, commandName: request.command.name, percentEncodedQuery: query)
		
		// Build a POST request.
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = HTTPMethod.post
		urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
		
		if let timeoutInterval = request.timeoutInterval {
			urlRequest.timeoutInterval = timeoutInterval
		}
		
		switch request.body {
		case .file(let url): return session.uploadTask(with: urlRequest, fromFile: url)
		case .data(let data): return session.uploadTask(with: urlRequest, from: data)
		}
	}
	
	/// Creates a `URLSessionDownloadTask` using a `URLSession` given a `Download.Request`.
	public static func createDownloadTask(with request: Download.Request, session: URLSession) -> URLSessionDownloadTask {
		var urlRequest = URLRequest(url: request.resourceAddress)
		
		if let timeoutInterval = request.timeoutInterval {
			urlRequest.timeoutInterval = timeoutInterval
		}
		
		for (name, value) in buildHTTPHeaderFields(withCookies: request.cookies, resourceAddress: request.resourceAddress) {
			urlRequest.addValue(value, forHTTPHeaderField: name)
		}
		
		return session.downloadTask(with: urlRequest)
	}
	
	private static func buildHTTPHeaderFields(withCookies cookies: [String: String], resourceAddress: URL) -> [String: String] {
		guard let host = resourceAddress.host else {
			return [:]
		}
		
		let path = resourceAddress.path
		
		let cookies = cookies.compactMap { name, value in
			HTTPCookie(properties: [.name: name, .value: value, .domain: host, .path: path])
		}
		
		return HTTPCookie.requestHeaderFields(with: cookies)
	}
	
	// Functions for encoding command parameter values to percent encoded strings.
	
	private static func encode(_ value: String) -> String {
		return value.addingPercentEncoding(withAllowedCharacters: .urlQueryParameterAllowedCharacterSetRFC3986())!
	}
	
	private static func encode(_ value: Bool) -> String {
		return value ? "1" : "0"
	}
	
	private static func encode(_ value: UInt64) -> String {
		return "\(value)"
	}
	
	
	// Functions for building a query string from command parameters.
	
	private static func rawQueryComponent(from parameter: Call.Command.Parameter) -> String {
		switch parameter {
		case let .boolean(name, value): return "\(name)=\(encode(value))"
		case let .number(name, value): return "\(name)=\(encode(value))"
		case let .string(name, value): return "\(name)=\(value)"
		}
	}
	
	private static func percentEncodedQueryComponent(from parameter: Call.Command.Parameter) -> String {
		switch parameter {
		case let .boolean(name, value): return "\(encode(name))=\(encode(value))"
		case let .number(name, value): return "\(encode(name))=\(encode(value))"
		case let .string(name, value): return "\(encode(name))=\(encode(value))"
		}
	}
	
	private static func buildQuery(with parameters: [Call.Command.Parameter], addingPercentEncoding encode: Bool) -> String {
		let components: [String]
		
		if encode {
			components = parameters.map(percentEncodedQueryComponent)
		} else {
			components = parameters.map(rawQueryComponent)
		}
		
		return components.joined(separator: "&")
	}
	
	private static func buildURL(withScheme scheme: String, host: String, commandName: String, query: String?) -> URL {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = "/\(commandName)"
		components.query = query
		
		return components.url!
	}
	
	private static func buildURL(withScheme scheme: String, host: String, commandName: String, percentEncodedQuery: String?) -> URL {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = "/\(commandName)"
		components.percentEncodedQuery = percentEncodedQuery
		
		return components.url!
	}
}

private struct HTTPMethod {
	static let get = "GET"
	static let post = "POST"
	static let put = "PUT"
}

private extension CharacterSet {
	// A character with characters allowed in a URL query as per RFC 3986.
	static func urlQueryParameterAllowedCharacterSetRFC3986() -> CharacterSet {
		return self.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
	}
}
