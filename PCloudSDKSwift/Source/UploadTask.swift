//
//  UploadTask.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Executes an upload to the pCloud API and produces an object on success from the API response.
public final class UploadTask<Method: PCloudApiMethod>: Cancellable {
	public typealias Parser = Method.Parser
	
	// The underlying operation executing the upload.
	fileprivate let operation: UploadOperation
	// A block taking a response dictionary and producing an object.
	fileprivate let parse: Parser
	
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
		parse = responseParser
	}
	
	/// Assigns a completion block to this instance to be called when the task completes either successfully or with a failure.
	///
	/// - parameter block: A block called on the main thread with the result of the task.
	/// - returns: This task.
	@discardableResult
	public func setCompletionBlock(_ block: @escaping (Result<Method.Value, Error>) -> Void) -> UploadTask {
		let parse = self.parse
		
		// Parse the response on a background queue.
		operation.setCompletionBlock(queue: .global()) { response in
			// Compute the response.
			let result: Result<Method.Value, Error> = {
				switch response {
				case .success(let response):
					do {
						return .success(try parse(response))
					} catch {
						return .failure(error)
					}
					
				case .failure(let error):
					switch error {
					case .clientError(let ce): return .failure(ce)
					case .protocolError(let pe): return .failure(pe)
					}
				}
			}()
			
			// Notify.
			DispatchQueue.main.async {
				block(result)
			}
		}
		
		return self
	}
	
	/// Assigns a progress block to this instance to be called continuously as data is being uploaded.
	///
	/// - parameter block: A block called on the main thread with the number of uploaded bytes and the total number of bytes to upload as
	/// first and second arguments, respectively. Called each time the number of uploaded bytes changes.
	/// - returns: This task.
	@discardableResult
	public func setProgressBlock(_ block: @escaping (Int64, Int64) -> Void) -> UploadTask {
		operation.setProgressBlock(queue: .main, block)
		return self
	}
	
	/// Starts the task if it is not already running.
	///
	/// - returns: This task.
	@discardableResult
	public func start() -> UploadTask {
		operation.enqueue()
		return self
	}
	
	/// Interrupts and invalidates the task. An invalidated task cannot run again.
	public func cancel() {
		operation.cancel()
	}
}

extension UploadTask: CustomStringConvertible {
	public var description: String {
		return "\(operation.state), id=\(operation.id), progress=\(operation.numberOfBytesSent) / \(operation.totalNumberOfBytesToSend), response=\(operation.response as Any)"
	}
}
