//
//  URLSessionBasedNetworkOperation.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Base class for network operations backed by `URLSessionTask`. Conforms to `NetworkOperation`. Forwards `URLSessionObserver` callbacks to blocks.
public class URLSessionBasedNetworkOperation<T> {
	public let task: URLSessionTask // The backing task.
	public var taskResponse: T? // The task response. Non-nil when the task completes.
	
	// A block to call on a specific queue when notifyCompletion() is called by subclasses.
	public var completion: (callback: (T) -> Void, queue: DispatchQueue?)?
	
	// Blocks corresponding to URLSessionObserver callbacks. Each one is named after the method it is called inside.
	public var didSendBodyData: ((Int64, Int64) -> Void)?
	public var didComplete: ((Error?) -> Void)?
	public var didReceiveData: ((Data) -> Void)?
	public var didFinishDownloading: ((URL) -> Void)?
	public var didWriteData: ((Int64, Int64) -> Void)?
	
	public init(task: URLSessionTask) {
		self.task = task
	}
	
	// If the completion tuple exists, calls the block on the queue passing the provided response as argument to the block.
	// If queue is nil, calls the block on the main queue. Used by subclasses. 
	public func notifyCompletion(response: T) {
		if let completion = completion {
			(completion.queue ?? .main).async {
				completion.callback(response)
			}
		}
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
	
	public func enqueue() {
		task.resume()
	}
	
	public func cancel() {
		task.cancel()
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
