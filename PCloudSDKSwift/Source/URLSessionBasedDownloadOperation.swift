//
//  URLSessionBasedDownloadOperation.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Concrete implementation of `DownloadOperation` backed by a `URLSessionDownloadTask`.
public final class URLSessionBasedDownloadOperation: URLSessionBasedNetworkOperation<Download.Response> {
	/// Initializes an operation with a task and destination.
	///
	/// - parameter task: A backing download task in a suspended state.
	/// - parameter destination: A block computing the destination of the downloaded file from its temporary location.
	init(task: URLSessionDownloadTask, destination: @escaping (URL) -> URL) {
		super.init(task: task)
		
		// Assign callbacks.
		// Expecting that didFinishDownloading will be called before didComplete and that both callbacks will be called
		// on the same thread.
		
		var moveResult: Result<URL>?
		
		didFinishDownloading = { path in
			// Compute destination.
			let finalPath = destination(path)
			
			// Attempt to move the file to its final destination.
			do {
				try FileManager.default.moveItem(at: path, to: finalPath)
				moveResult = .success(finalPath)
			} catch {
				moveResult = .failure(error)
			}
		}
		
		didComplete = { [weak self] error in
			guard let me = self, !me.isCancelled else {
				return
			}
			
			// Compute response.
			let response: Download.Response = {
				if let error = error {
					return .failure(error)
				}
				
				return moveResult!
			}()
			
			// Complete.
			me.taskResponse = response
			me.notifyCompletion(response: response)
		}
	}
}

extension URLSessionBasedDownloadOperation: DownloadOperation {
	public var response: Download.Response? {
		return taskResponse
	}
	
	public var numberOfBytesReceived: Int64 {
		return task.countOfBytesReceived
	}
	
	public var totalNumberOfBytesToReceive: Int64 {
		return task.countOfBytesExpectedToReceive
	}
	
	@discardableResult
	public func setCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Download.Response) -> Void) -> URLSessionBasedDownloadOperation {
		completion = (block, queue)
		return self
	}
	
	@discardableResult
	public func setProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> URLSessionBasedDownloadOperation {
		// Call the progress block on the main queue unless explicitly requested otherwise.
		didWriteData = { written, total in
			(queue ?? .main).async {
				block(written, total)
			}
		}
		
		return self
	}
}

extension URLSessionBasedDownloadOperation: CustomStringConvertible {
	public var description: String {
		return "\(state), id=\(id), progress=\(numberOfBytesReceived) / \(totalNumberOfBytesToReceive), response=\(response)"
	}
}
