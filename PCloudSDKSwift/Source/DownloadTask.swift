//
//  DownloadTask.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// A wrapper around `DownloadOperation`. Downloads a file to disk.
public final class DownloadTask: Cancellable {
	// The underlying download opearation.
	fileprivate let operation: DownloadOperation
	
	/// `true` if `cancel()` has been invoked on this task, `false` otherwise.
	public var isCancelled: Bool {
		return operation.isCancelled
	}
	
	/// Initializes a new download task.
	///
	/// - parameter operation: An operation in a suspended state that would execute the download.
	public init(operation: DownloadOperation) {
		self.operation = operation
	}
	
	/// Assigns a progress block to this instance to be called continuously as data is being downloaded.
	///
	/// - parameter block: A block called on the main thread with the number of downloaded bytes and the total number of bytes to download as
	/// first and second arguments, respectively. Called each time the number of downloaded bytes changes.
	/// - returns: This task.
	@discardableResult
	public func setProgressBlock(_ block: @escaping (Int64, Int64) -> Void) -> DownloadTask {
		operation.addProgressBlock(queue: .main, block)
		return self
	}
	
	/// Assigns a completion block to this instance to be called when the task completes either successfully or with a failure.
	///
	/// - parameter block: A block called on the main thread with the result of the task.
	/// - returns: This task.
	@discardableResult
	public func setCompletionBlock(_ block: @escaping (Download.Response) -> Void) -> DownloadTask {
		operation.addCompletionBlock(queue: .main, block)
		return self
	}
	
	/// Starts the task if it is not already running.
	/// - returns: This task.
	@discardableResult
	public func start() -> DownloadTask {
		operation.enqueue()
		return self
	}
	
	/// Interrupts and invalidates this task. An invalidated task cannot run again.
	public func cancel() {
		operation.cancel()
	}
}

extension DownloadTask: CustomStringConvertible {
	public var description: String {
		return "\(operation.state), id=\(operation.id), progress=\(operation.numberOfBytesReceived) / \(operation.totalNumberOfBytesToReceive), response=\(operation.response as Any)"
	}
}
