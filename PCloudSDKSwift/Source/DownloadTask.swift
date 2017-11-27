//
//  DownloadTask.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// A non-reusable mediator managing a task for obtaining an address for a resource, and a task for downloading the resource from
/// the produced address. Intended for simple use cases. Only use on the main thread.
public final class DownloadTask: Cancellable {
	public typealias AddressProvider = (@escaping (Result<URL, Error>) -> Void) -> Cancellable
	public typealias OperationBuilder = (URL) -> DownloadOperation
	
	// A block performing the task of obtaining a resource address.
	fileprivate let addressProvider: AddressProvider
	// A block creating a download operation for a resource address.
	fileprivate let operationBuilder: OperationBuilder
	// Represents the cancellation state of this task before a resource address is obtained.
	fileprivate var task: Cancellable = AnyCancellationToken()
	// The underlying download opearation. Created after address is obtained.
	fileprivate var operation: DownloadOperation?
	// A completion block to call when this task completes.
	fileprivate var completionBlock: ((Download.Response) -> Void)?
	// A progress block to call as the file is downloaded.
	fileprivate var progressBlock: ((Int64, Int64) -> Void)?
	// true if start() has been called on this instance, false otherwise.
	fileprivate var isConsumed: Bool = false
	// Holds this task in memory while it is running.
	fileprivate var memory: Any?
	
	/// `true` if `cancel()` has been invoked on this task, `false` otherwise.
	public var isCancelled: Bool {
		return task.isCancelled || (operation?.isCancelled ?? false)
	}
	
	/// Initializes a new task with a block for obtaining a resource address and a block for creating a download operation from a resource address.
	///
	/// - parameter addressProvider: A block obtaining a resource address asynchronously. When the task completes, the completion block passed
	/// as the parameter to this block should be called on the main thread. Referenced strongly by the task.
	/// - parameter operationBuilder: A block creating a download operation from a resource address. Referenced strongly by the task.
	public init(addressProvider: @escaping AddressProvider, operationBuilder: @escaping OperationBuilder) {
		self.addressProvider = addressProvider
		self.operationBuilder = operationBuilder
	}
	
	/// Assigns a progress block to this instance to be called continuously as data is being downloaded.
	///
	/// - parameter block: A block called on the main thread with the number of downloaded bytes and the total number of bytes to download as
	/// first and second arguments, respectively. Called each time the number of downloaded bytes changes.
	/// - returns: This task.
	@discardableResult
	public func setProgressBlock(_ block: @escaping (Int64, Int64) -> Void) -> DownloadTask {
		progressBlock = block
		return self
	}
	
	/// Assigns a completion block to this instance to be called when the task completes either successfully or with a failure.
	///
	/// - parameter block: A block called on the main thread with the result of the task.
	/// - returns: This task.
	@discardableResult
	public func setCompletionBlock(_ block: @escaping (Download.Response) -> Void) -> DownloadTask {
		completionBlock = block
		return self
	}
	
	/// Starts the task if it is not already running.
	/// - returns: This task.
	@discardableResult
	public func start() -> DownloadTask {
		guard !isCancelled && !isConsumed else {
			return self
		}
		
		isConsumed = true
		createRetainCycle() // Ensure this instance stays in memory while it is executing.
		
		// Start obtaining the resource address.
		task = addressProvider { [weak self] response in
			guard let me = self else {
				return
			}
			
			switch response {
			case .success(let address): me.download(from: address)
			case .failure(let error): me.complete(result: .failure(.clientError(error)))
			}
		}
		
		return self
	}
	
	/// Interrupts and invalidates this task. An invalidated task cannot run again.
	public func cancel() {
		task.cancel() // Cancel the initial cancellation token or the address task.
		operation?.cancel() // Cancel the download.
		breakRetainCycle() // This task no longers needs to stay in memory.
	}
	
	// Breaks the retain cycle and invokes this task's completion block.
	private func complete(result: Download.Response) {
		breakRetainCycle()
		completionBlock?(result)
	}
	
	// Creates sets up a download operation, assigns it to this task and starts it.
	private func download(from address: URL) {
		let operation = operationBuilder(address)
		
		operation.setCompletionBlock(queue: .main) { [weak self] response in
			self?.complete(result: response)
		}
		
		operation.setProgressBlock(queue: .main) { [weak self] written, total in
			self?.progressBlock?(written, total)
		}
		
		operation.enqueue()
		self.operation = operation
	}
	
	private func createRetainCycle() {
		memory = self
	}
	
	private func breakRetainCycle() {
		memory = nil
	}
}

extension DownloadTask: CustomStringConvertible {
	public var description: String {
		if let operation = operation {
			return "\(operation.state), id=\(operation.id), progress=\(operation.numberOfBytesReceived) / \(operation.totalNumberOfBytesToReceive), response=\(operation.response as Any)"
		}
		
		return "ACQUIRING RESOURCE ADDRESS"
	}
}
