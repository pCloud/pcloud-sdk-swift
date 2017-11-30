//
//  UploadTask.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Executes an upload to the pCloud API.
public final class UploadTask<Method: PCloudAPIMethod>: Cancellable {
	public typealias Parser = Method.Parser
	public typealias CompletionBlock = (Result<Method.Value, CallError<Method.Error>>) -> Void
	
	// The underlying operation executing the upload.
	fileprivate let operation: UploadOperation
	
	fileprivate let lock = Lock()
	fileprivate var completionBlocks: [CompletionBlock] = []
	
	/// `true` if `cancel()` has been invoked on this instance, `false` otherwise.
	public var isCancelled: Bool {
		return operation.isCancelled
	}
	
	/// Initializes a non-running task with a network operation and a parser.
	///
	/// - parameter operation: An operation in a suspended state that would execute the upload.
	/// - parameter responseParser: A block parsing an object from a response dictionary.
	public init(operation: UploadOperation, responseParser: @escaping Parser) {
		self.operation = operation
		
		// Parse the response on a background queue.
		operation.addCompletionBlock(queue: .global()) { response in
			// Compute the response.
			let result: Result<Method.Value, CallError<Method.Error>> = {
				switch response {
				case .failure(.clientError(let error)):
					return .failure(.clientError(error))
					
				case .failure(.protocolError(let error)):
					return .failure(.protocolError(error))
					
				case .success(let payload):
					do {
						return try responseParser(payload).replacingError { error in
							CallError<Method.Error>(apiError: error)
						}
					} catch {
						return .failure(.clientError(error))
					}
				}
			}()
			
			// Notify observers.
			let completionBlocks: [CompletionBlock] = self.lock.inCriticalScope {
				defer { self.completionBlocks.removeAll() }
				return self.completionBlocks
			}
			
			DispatchQueue.main.async {
				for block in completionBlocks {
					block(result)
				}
			}
		}
	}
	
	/// Adds a completion block to this instance to be called when the task completes either successfully or with a failure.
	///
	/// - parameter block: A block called on the main thread with the result of the task.
	/// - returns: This task.
	@discardableResult
	public func addCompletionBlock(_ block: @escaping CompletionBlock) -> UploadTask {
		lock.inCriticalScope {
			completionBlocks.append(block)
		}
		
		return self
	}
	
	/// Adds a progress block to this instance to be called continuously as data is being uploaded.
	///
	/// - parameter block: A block called on the main thread with the number of uploaded bytes and the total number of bytes to upload as
	/// first and second arguments, respectively. Called each time the number of uploaded bytes changes.
	/// - returns: This task.
	@discardableResult
	public func addProgressBlock(_ block: @escaping (Int64, Int64) -> Void) -> UploadTask {
		operation.addProgressBlock(queue: .main, block)
		return self
	}
	
	/// Starts the task if it is not already running.
	///
	/// - returns: This task.
	@discardableResult
	public func start() -> UploadTask {
		operation.start()
		return self
	}
	
	/// Interrupts and invalidates the task. An invalidated task cannot run again.
	public func cancel() {
		operation.cancel()
		
		lock.inCriticalScope {
			completionBlocks.removeAll()
		}
	}
}

extension UploadTask: CustomStringConvertible {
	public var description: String {
		return "\(operation.state), id=\(operation.id), progress=\(operation.numberOfBytesSent) / \(operation.totalNumberOfBytesToSend), response=\(operation.response as Any)"
	}
}
