//
//  URLSessionBasedNetworkOperation.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// Base class for network operations backed by `URLSessionTask`. Conforms to `NetworkOperation`. Forwards `URLSessionObserver` callbacks to blocks.
public class URLSessionBasedNetworkOperation<T> {
	typealias CompletionHandler = (callback: (T) -> Void, queue: DispatchQueue?)
	typealias ProgressHandler = (callback: (Int64, Int64) -> Void, queue: DispatchQueue?)
	
	// The task response. Non-nil when the task completes.
	var taskResponse: T? {
		return lock.inCriticalScope { _taskResponse }
	}
	
	let task: URLSessionTask // The backing task.
	
	// Blocks corresponding to URLSessionObserver callbacks. Each one is named after the method it is called inside.
	var didSendBodyData: ((Int64, Int64) -> Void)?
	var didComplete: ((Error?) -> Void)?
	var didReceiveData: ((Data) -> Void)?
	var didFinishDownloading: ((URL) -> Void)?
	var didWriteData: ((Int64, Int64) -> Void)?
	
	
	private var _taskResponse: T? // The backing storage for taskResponse. Always access via the lock.
	
	// Blocks to call on a specific queue when notifyCompletion() is called by subclasses.
	// Do not access directly and use the addCompletionHandler() and notifyCompletion() methods instead.
	private var completionHandlers: [CompletionHandler] = []
	
	// Blocks to call on a specific queue when notifyProgress() is called by subclasses.
	// Do not access directly and use the addProgressHandler() and notifyProgress() methods instead.
	private var progressHandlers: [ProgressHandler] = []
	
	private let lock = Lock() // Used to protect completion and progress handlers.
	
	init(task: URLSessionTask) {
		self.task = task
	}
	
	// Assigns the response to the taskResponse property, removes all completion and progress handlers and
	// calls all completion handler blocks either on the handler's queue or on the main queue if the handler's queue is nil.
	func complete(response: T) {
		let completionHandlers: [CompletionHandler] = lock.inCriticalScope {
			defer {
				self.completionHandlers.removeAll()
				progressHandlers.removeAll()
			}
			
			_taskResponse = response
			return self.completionHandlers
		}
		
		for handler in completionHandlers {
			(handler.queue ?? .main).async {
				handler.callback(response)
			}
		}
	}
	
	// Calls all progress handler blocks with the provided arguments either on the handler's queue
	// or on the main queue if the handler's queue is nil.
	func notifyProgress(units: Int64, outOf totalUnits: Int64) {
		let progressHandlers = lock.inCriticalScope {
			self.progressHandlers
		}
		
		for handler in progressHandlers {
			(handler.queue ?? .main).async {
				handler.callback(units, totalUnits)
			}
		}
	}
	
	func addCompletionHandler(_ handler: CompletionHandler) {
		lock.inCriticalScope {
			completionHandlers.append(handler)
		}
	}
	
	func addProgressHandler(_ handler: ProgressHandler) {
		lock.inCriticalScope {
			progressHandlers.append(handler)
		}
	}
	
	func errorIsCancellation(_ err: Error) -> Bool {
		let error = err as NSError
		return error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled
	}
}


extension URLSessionBasedNetworkOperation: NetworkOperation {
	public var id: Int {
		return task.taskIdentifier
	}
	
	public var state: NetworkOperationState {
		return NetworkOperationState(state: task.state)
	}
	
	public var isCancelled: Bool {
		return state == .cancelled
	}
	
	public func start() {
		task.resume()
	}
	
	public func cancel() {
		task.cancel()
		
		lock.inCriticalScope {
			completionHandlers.removeAll()
			progressHandlers.removeAll()
		}
	}
}

extension URLSessionBasedNetworkOperation: URLSessionObserver {
	public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		didSendBodyData?(totalBytesSent, totalBytesExpectedToSend)
	}
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		didComplete?(error)
	}
	
	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		didReceiveData?(data)
	}
	
	public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		didFinishDownloading?(location)
	}
	
	public func urlSession(_ session: URLSession,
	                       downloadTask: URLSessionDownloadTask,
	                       didWriteData bytesWritten: Int64,
	                       totalBytesWritten: Int64,
	                       totalBytesExpectedToWrite: Int64) {
		didWriteData?(totalBytesWritten, totalBytesExpectedToWrite)
	}
}

extension NetworkOperationState {
	public init(state: URLSessionTask.State) {
		switch state {
		case .running: self = .running
		case .suspended: self = .suspended
		case .completed: self = .completed
		case .canceling: self = .cancelled
		@unknown default: fatalError("unhandled or invalid url session state \(state.rawValue)")
		}
	}
}

extension NetworkOperationState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .running: return "RUNNING"
		case .suspended: return "SUSPENDED"
		case .completed: return "COMPLETED"
		case .cancelled: return "CANCELLED"
		}
	}
}
