//
//  CallTask.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Executes a network call to the pCloud API and produces an object on success from the API response.
public final class CallTask<Method: PCloudApiMethod>: Cancellable {
	public typealias Parser = Method.Parser
	
	// The underlying operation executing the network call.
	fileprivate let operation: CallOperation
	// A block taking a response dictionary and producing an object.
	fileprivate let parse: Parser
	
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
		parse = responseParser
	}
	
	/// Assigns a completion block to this instance to be called when the task completes either successfully or with a failure.
	///
	/// - parameter block: A block called on the main thread with the result of the task.
	/// - returns: This task.
	@discardableResult
	public func setCompletionBlock(_ block: @escaping (Result<Method.Value>) -> Void) -> CallTask {
		let parse = self.parse
		
		// Parse the response on a background queue.
		operation.setCompletionBlock(queue: .global()) { response in
			// Compute the response.
			let result: Result<Method.Value> = {
				switch response {
				case .success(let response):
					do {
						return .success(try parse(response))
					} catch {
						return .failure(error)
					}
					
				case .failure(let error):
					return .failure(error)
				}
			}()
			
			DispatchQueue.main.async {
				// Notify.
				block(result)
			}
		}
		
		return self
	}
	
	/// Starts the task if it is not already running.
	///
	/// - returns: This task.
	@discardableResult
	public func start() -> CallTask {
		operation.enqueue()
		return self
	}
	
	/// Interrupts and invalidates the task. An invalidated task cannot run again.
	public func cancel() {
		operation.cancel()
	}
}

extension CallTask: CustomStringConvertible {
	public var description: String {
		return "\(operation.state), id=\(operation.id), response=\(operation.response)"
	}
}
