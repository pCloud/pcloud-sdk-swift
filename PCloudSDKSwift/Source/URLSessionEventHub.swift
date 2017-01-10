//
//  URLSessionEventHub.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Object handling callbacks from a `URLSession`.
public protocol URLSessionObserver {
	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
	func urlSession(_ session: URLSession,
	                downloadTask: URLSessionDownloadTask,
	                didWriteData bytesWritten: Int64,
	                totalBytesWritten: Int64,
	                totalBytesExpectedToWrite: Int64)
}


/// Forwards callbacks from a `URLSession` to objects implementing `URLSessionObserver`. Assigns a single observer per `URLSessionTask` and that observer
/// receives all callbacks associated with that task.
public final class URLSessionEventHub: NSObject {
	// URLSessionTask identifiers mapped to observers.
	fileprivate var observers = Atomic<[Int: URLSessionObserver]>([:])
	
	// Returns an observer for a task.
	fileprivate subscript(_ task: URLSessionTask) -> URLSessionObserver? {
		return observers.value[task.taskIdentifier]
	}
	
	/// Assigns an observer for a specific `URLSessionTask`. This unassigns the previous observer to the provided task.
	/// The new observer will receive all callbacks for `task` until it is explicitly removed from this instance, or, if
	/// `task` completes. A task is considered completed when 
	/// ```
	/// urlSession(:task:didCompleteWithError:)
	/// ```
	/// is invoked in which case the hub will forward this last call to its observer and then remove it.
	///
	/// - parameter observer: An object that will receive all callbacks for `task`.
	/// - parameter task: The task to associate with `observer`.
	public func setObserver(_ observer: URLSessionObserver, for task: URLSessionTask) {
		set(observer, for: task)
	}
	
	/// Removes the observer for a specific `URLSessionTask`, if one exists.
	///
	/// - parameter task: The task to stop observing.
	public func removeObserver(for task: URLSessionTask) {
		set(nil, for: task)
	}
	
	// Assigns an observer for a task and returns the old observer, if any.
	@discardableResult
	fileprivate func set(_ observer: URLSessionObserver?, for task: URLSessionTask) -> URLSessionObserver? {
		let key = task.taskIdentifier
		
		return observers.modify {
			var copy = $0
			copy[key] = observer
			return copy
		}[key]
	}
}


// MARK:- Conforming to URLSession delegate protocols.

extension URLSessionEventHub: URLSessionTaskDelegate {
	public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		self[task]?.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
	}
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		// Remove the observer and forward this callback to it.
		set(nil, for: task)?.urlSession(session, task: task, didCompleteWithError: error)
	}
}

extension URLSessionEventHub: URLSessionDataDelegate {
	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		self[dataTask]?.urlSession(session, dataTask: dataTask, didReceive: data)
	}
}

extension URLSessionEventHub: URLSessionDownloadDelegate {
	public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		self[downloadTask]?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
	}
	
	public func urlSession(_ session: URLSession,
	                       downloadTask: URLSessionDownloadTask,
	                       didWriteData bytesWritten: Int64,
	                       totalBytesWritten: Int64,
	                       totalBytesExpectedToWrite: Int64) {
		self[downloadTask]?.urlSession(session,
		                               downloadTask: downloadTask,
		                               didWriteData: bytesWritten,
		                               totalBytesWritten: totalBytesWritten,
		                               totalBytesExpectedToWrite: totalBytesExpectedToWrite)
	}
}
