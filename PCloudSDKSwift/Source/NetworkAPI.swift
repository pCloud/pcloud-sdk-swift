//
//  NetworkAPI.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// The possible execution states of a network operation.
public enum NetworkOperationState {
	/// The operation is not running.
	case suspended
	
	/// The operation is running.
	case running
	
	/// The operation has completed either successfully or due to a failure.
	case completed
	
	/// The operation has been cancelled.
	case cancelled
}


/// Base interface for a network operation.
public protocol NetworkOperation: Cancellable {
	/// Unique identifier of the operation.
	var id: Int { get }
	
	/// Current state of the operation.
	var state: NetworkOperationState { get }
	
	/// If the state of the operation is `NetworkOperationState.suspended`, enqueues it to run as soon as possible.
	/// Does nothing otherwise.
	func start()
}


/// An error from a network operation.
public enum NetworkOperationError {
	case clientError(Error)
	case protocolError(Error)
}


/// Call namespace.
public struct Call {
	/// A result from executing a pCloud API call.
	public typealias Response = Result<[String: Any], NetworkOperationError>
	
	/// A pCloud API command. Describes what the API should do.
	public struct Command {
		public enum Parameter {
			case boolean(name: String, value: Bool)
			case number(name: String, value: UInt64)
			case string(name: String, value: String)
		}
		
		/// The name of this command.
		public var name: String
		
		/// Parameters to this command.
		public var parameters: [Parameter]
		
		public init(name: String, parameters: [Parameter]) {
			self.name = name
			self.parameters = parameters
		}
	}
	
	/// Combines all the necessary input to execute a pCloud API call.
	public struct Request {
		/// A command.
		public var command: Command
		
		/// An API host name.
		public var hostName: String
		
		/// The maximum amount of time (in seconds) that an operation's load activity can execute
		/// while the operation is running.
		public var timeoutInterval: TimeInterval?
		
		public init(command: Command, hostName: String, timeoutInterval: TimeInterval? = nil) {
			self.command = command
			self.hostName = hostName
			self.timeoutInterval = timeoutInterval
		}
	}
}


/// A network operation that knows how to execute a pCloud API call. 
public protocol CallOperation: NetworkOperation {
	/// The result from executing the API call. Exists only when `state` is `NetworkOperationState.completed`.
	var response: Call.Response? { get }
	
	/// Adds a block to be called on a specific queue when the operation receives its response.
	///
	/// - parameter queue: A queue to call `block` on. If `nil`, the queue on which `block` will be called is undefined.
	/// - parameter block: Called as soon as the operation receives its response. Referenced strongly by the operation.
	@discardableResult func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Call.Response) -> Void) -> Self
}



/// Upload namespace.
public struct Upload {
	/// A result from executing an upload to pCloud.
	public typealias Response = Result<[String: Any], NetworkOperationError>
	
	/// Combines all the necessary input to execute an upload to pCloud.
	public struct Request {
		/// The source of the upload data.
		public enum Body {
			/// A file identified by a local path.
			case file(URL)
			
			/// An in-memory buffer identified by a `Data` object.
			case data(Data)
		}
		
		/// A command.
		public var command: Call.Command
		
		/// The upload data.
		public var body: Body
		
		/// An API host name.
		public var hostName: String
		
		/// The maximum amount of time (in seconds) that an operation's load activity can execute
		/// while the operation is running.
		public var timeoutInterval: TimeInterval?
		
		public init(command: Call.Command, body: Body, hostName: String, timeoutInterval: TimeInterval? = nil) {
			self.command = command
			self.body = body
			self.hostName = hostName
			self.timeoutInterval = timeoutInterval
		}
	}
}


/// A network operation that knows how to execute an upload to pCloud.
public protocol UploadOperation: NetworkOperation {
	/// The result from executing the upload. Exists only when `state` is `NetworkOperationState.completed`.
	var response: Upload.Response? { get }
	
	/// The number of bytes currently uploaded.
	var numberOfBytesSent: Int64 { get }
	
	/// The total number of bytes to upload.
	var totalNumberOfBytesToSend: Int64 { get }
	
	/// Adds a block to be called on a specific queue when `numberOfBytesSent` changes.
	///
	/// - parameter queue: A queue to call `block` on. If `nil`, the queue on which `block` will be called is undefined.
	/// - parameter block: A block called with the number of bytes currently uploaded and the total number of bytes to upload as first
	/// and second input arguments respectivly. Referenced strongly by the operation.
	@discardableResult func addProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> Self
	
	/// Adds a block to be called on a specific queue when the operation receives its response.
	///
	/// - parameter queue: A queue to call `block` on. If `nil`, the queue on which `block` will be called is undefined.
	/// - parameter block: Called as soon as the operation receives its response. Referenced strongly by the operation.
	@discardableResult func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Upload.Response) -> Void) -> Self
}


/// Download namespace.
public struct Download {
	/// A result from executing a download from pCloud.
	public typealias Response = Result<URL, NetworkOperationError>
	
	/// Combines all the necessary input to execute an HTTP download.
	public struct Request {
		/// The remote address of the resource to download.
		public var resourceAddress: URL
		
		/// A block called with the temporary location of the file on disk. The block must either move
		/// the file or open it for reading, otherwise the file gets deleted after the block returns.
		/// The block should return the new path of the file.
		public var destination: (URL) throws -> URL
		
		/// The maximum amount of time (in seconds) that an operation's load activity can execute
		/// while the operation is running.
		public var timeoutInterval: TimeInterval?
		
		/// Cookies to send along the HTTP request.
		public var cookies: [String: String]
		
		public init(resourceAddress: URL, cookies: [String: String] = [:], timeoutInterval: TimeInterval? = nil, destination: @escaping (URL) throws -> URL) {
			self.resourceAddress = resourceAddress
			self.destination = destination
			self.cookies = cookies
			self.timeoutInterval = timeoutInterval
		}
	}
}


/// A network operation that knows how to execute a download.
public protocol DownloadOperation: NetworkOperation {
	/// The result from executing the download. Exists only when `state` is `NetworkOperationState.completed`.
	var response: Download.Response? { get }
	
	/// The number of bytes currently downloaded.
	var numberOfBytesReceived: Int64 { get }
	
	/// The total number of bytes to download.
	var totalNumberOfBytesToReceive: Int64 { get }
	
	/// Adds a block to be called on a specific queue when `numberOfBytesReceived` changes.
	///
	/// - parameter queue: A queue to call `block` on. If `nil`, the queue on which `block` will be called is undefined.
	/// - parameter block: A block called with the number of bytes currently uploaded and the total number of bytes to upload as first
	/// and second input arguments respectivly. Referenced strongly by the operation.
	@discardableResult func addProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> Self
	
	/// Adds a block to be called on a specific queue when the operation receives its response.
	///
	/// - parameter queue: A queue to call `block` on. If `nil`, the queue on which `block` will be called is undefined.
	/// - parameter block: Called as soon as the operation receives its response. Referenced strongly by the operation.
	@discardableResult func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Download.Response) -> Void) -> Self
}


// MARK:- Utility protocol conformances.

extension Call.Command.Parameter: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .string(name, value): return "\(name):\(value)"
		case let .number(name, value): return "\(name):\(value)"
		case let .boolean(name, value): return "\(name):\(value)"
		}
	}
}

extension Call.Command.Parameter: Hashable {
}


extension Call.Command: CustomStringConvertible {
	public var description: String {
		return "\(name), \(parameters)"
	}
}

extension Call.Command: Equatable {
}

public func ==(lhs: Call.Command, rhs: Call.Command) -> Bool {
	return lhs.name == rhs.name && Set(lhs.parameters) == Set(rhs.parameters)
}

extension Call.Request: CustomStringConvertible {
	public var description: String {
		return "\(hostName), \(command)"
	}
}

extension Upload.Request: CustomStringConvertible {
	public var description: String {
		var result = "\(hostName), \(command), "
		
		switch body {
		case .file(let url): result += url.description
		case .data(let data): result += "\(data.count) bytes"
		}
		
		return result
	}
}

extension Download.Request: CustomStringConvertible {
	public var description: String {
		return resourceAddress.description
	}
}
