//
//  APITaskBuilding.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Utility struct containing logic for building `CallTask` instances for `PCloudAPIMethod`s.
public struct PCloudAPICallTaskBuilder {
	fileprivate let hostProvider: HostProvider
	fileprivate let authenticator: Authenticator
	fileprivate let operationBuilder: (Call.Request) -> CallOperation
	fileprivate let defaultTimeoutInterval: TimeInterval?
	
	public init(hostProvider: HostProvider,
				authenticator: Authenticator,
				defaultTimeoutInterval: TimeInterval? = nil,
				operationBuilder: @escaping (Call.Request) -> CallOperation) {
		self.hostProvider = hostProvider
		self.authenticator = authenticator
		self.operationBuilder = operationBuilder
		self.defaultTimeoutInterval = defaultTimeoutInterval
	}
	
	/// Creates a `CallTask` instance executing a specific API method.
	///
	/// - parameter method: A method for the task to execute.
	/// - parameter hostNameOverride: If non-`nil`, this will override the default host name from the host provider.
	/// - parameter timeoutInterval: The timeout interval for this call task. If `nil`, the default timeout interval will be used.
	/// - returns: An instance of `CallTask` in suspended state.
	public func createTask<T: PCloudAPIMethod>(for method: T,
											   hostNameOverride: String? = nil,
											   timeoutInterval: TimeInterval? = nil) -> CallTask<T> {
		var command = method.createCommand()
		
		if method.requiresAuthentication {
			command.parameters.append(contentsOf: authenticator.authenticationParameters)
		}
		
		let request = Call.Request(command: command,
								   hostName: hostNameOverride ?? hostProvider.defaultHostName,
								   timeoutInterval: timeoutInterval ?? defaultTimeoutInterval)
		
		let operation = operationBuilder(request)
		let responseParser = method.createResponseParser()
		
		return CallTask(operation: operation, responseParser: responseParser)
	}
}


/// Utility struct containing logic for building `UploadTask` instances for `PCloudAPIMethod`s.
public struct PCloudAPIUploadTaskBuilder {
	fileprivate let hostProvider: HostProvider
	fileprivate let authenticator: Authenticator
	fileprivate let operationBuilder: (Upload.Request) -> UploadOperation
	fileprivate let defaultTimeoutInterval: TimeInterval?
	
	public init(hostProvider: HostProvider,
				authenticator: Authenticator,
				defaultTimeoutInterval: TimeInterval? = nil,
				operationBuilder: @escaping (Upload.Request) -> UploadOperation) {
		self.hostProvider = hostProvider
		self.authenticator = authenticator
		self.operationBuilder = operationBuilder
		self.defaultTimeoutInterval = defaultTimeoutInterval
	}
	
	/// Creates an `UploadTask` instance executing a specific API method.
	///
	/// - parameter method: A method for the task to execute.
	/// - parameter body: The data to upload.
	/// - parameter hostNameOverride: If non-`nil`, this will override the default host name from the host provider.
	/// - parameter timeoutInterval: The timeout interval for this call task. If `nil`, the default timeout interval will be used.
	/// - returns: An instance of `UploadTask` in suspended state.
	public func createTask<T: PCloudAPIMethod>(for method: T,
											   with body: Upload.Request.Body,
											   hostNameOverride: String? = nil,
											   timeoutInterval: TimeInterval? = nil) -> UploadTask<T> {
		var command = method.createCommand()
		
		if method.requiresAuthentication {
			command.parameters.append(contentsOf: authenticator.authenticationParameters)
		}
		
		let request = Upload.Request(command: command,
									 body: body,
									 hostName: hostNameOverride ?? hostProvider.defaultHostName,
									 timeoutInterval: timeoutInterval ?? defaultTimeoutInterval)
		
		let operation = operationBuilder(request)
		let responseParser = method.createResponseParser()
		
		return UploadTask(operation: operation, responseParser: responseParser)
	}
}

/// Utility struct containing logic for building `DownloadTask` instances.
public struct PCloudAPIDownloadTaskBuilder {
	fileprivate let hostProvider: HostProvider
	fileprivate let authenticator: Authenticator
	fileprivate let defaultTimeoutInterval: TimeInterval?
	fileprivate let operationBuilder: (Download.Request) -> DownloadOperation
	
	public init(hostProvider: HostProvider,
				authenticator: Authenticator,
				defaultTimeoutInterval: TimeInterval? = nil,
				operationBuilder: @escaping (Download.Request) -> DownloadOperation) {
		self.hostProvider = hostProvider
		self.authenticator = authenticator
		self.operationBuilder = operationBuilder
		self.defaultTimeoutInterval = defaultTimeoutInterval
	}
	
	/// Creates a `DownloadTask` instance for downloading a file from a remote address.
	///
	/// - parameter resourceAddress: The location of the file to download.
	/// - parameter destination: A block called with the temporary location of the file on disk. The block must either move
	/// the file or open it for reading, otherwise the file gets deleted after the block returns.
	/// The block should return the new path of the file.
	/// - parameter downloadTag: To be passed alongside `FileLink.Metadata` resource addresses. Authenticates this client to the storage servers.
	/// - parameter timeoutInterval: The timeout interval for this call task. If `nil`, the default timeout interval will be used.
	/// - returns: An instance of `DownloadTask` in suspended state.
	public func createTask(resourceAddress: URL,
						   destination: @escaping (URL) throws -> URL,
						   downloadTag: String? = nil,
						   timeoutInterval: TimeInterval? = nil) -> DownloadTask {
		let cookies: [String: String] = {
			if let downloadTag = downloadTag {
				return ["dwltag": downloadTag]
			}
			
			return [:]
		}()
		
		let request = Download.Request(resourceAddress: resourceAddress,
									   destination: destination,
									   cookies: cookies,
									   timeoutInterval: timeoutInterval ?? defaultTimeoutInterval)
		
		let operation = operationBuilder(request)
		return DownloadTask(operation: operation)
	}
}
