//
//  CallTask.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation


/// Executes a network call to the pCloud API.
public final class CallTask<Method: PCloudAPIMethod>: Cancellable {
	public typealias Parser = Method.Parser
	public typealias CompletionBlock = (Result<Method.Value, CallError<Method.Error>>) -> Void
	
	// The underlying operation executing the network call.
	fileprivate let operation: CallOperation
	
	fileprivate let lock = Lock()
	fileprivate var completionBlocks: [CompletionBlock] = []
	
	/// `true` if `cancel()` has been invoked on this instance, `false` otherwise.
	public var isCancelled: Bool {
		return operation.isCancelled
	}
	
	/// Initializes a non-running task with a network operation and a parser.
	///
	/// - parameter operation: An operation in a suspended state that would execute the network call.
	/// - parameter responseParser: A block parsing an object from a response dictionary.
	public init(operation: CallOperation, responseParser: @escaping Parser) {
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
	public func addCompletionBlock(_ block: @escaping CompletionBlock) -> CallTask {
		lock.inCriticalScope {
			completionBlocks.append(block)
		}
		
		return self
	}
	
	/// Starts the task if it is not already running.
	///
	/// - returns: This task.
	@discardableResult
	public func start() -> CallTask {
		operation.start()
		return self
	}
	
	/// Interrupts and invalidates the task. An invalidated task cannot run again.
	public func cancel() {
		operation.cancel()
	}
}

extension CallTask: CustomStringConvertible {
	public var description: String {
		return "\(operation.state), id=\(operation.id), response=\(operation.response as Any)"
	}
}
