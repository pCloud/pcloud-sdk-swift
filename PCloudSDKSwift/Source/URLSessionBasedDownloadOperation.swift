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
	/// - parameter destination: A block called with the temporary location of the downloaded file on disk.
	/// The block must either move or open the file for reading before it returns, otherwise the file gets deleted.
	/// The block should return the new location of the file.
	public init(task: URLSessionDownloadTask, destination: @escaping (URL) throws -> URL) {
		super.init(task: task)
		
		// Assign callbacks.
		// Expecting that didFinishDownloading will be called before didComplete and that both callbacks will be called
		// on the same thread.
		
		didWriteData = { [weak self] written, total in
			self?.notifyProgress(units: written, outOf: total)
		}
		
		var moveResult: Result<URL, NetworkOperationError>?
		
		didFinishDownloading = { path in
			do {
				moveResult = .success(try destination(path))
			} catch {
				moveResult = .failure(.clientError(error))
			}
		}
		
		didComplete = { [weak self] error in
			guard let me = self, !me.isCancelled else {
				return
			}
			
			// Compute response.
			let response: Download.Response = {
				if let error = error {
					return .failure(.clientError(error))
				}
				
				return moveResult!
			}()
			
			// Complete.
			me.complete(response: response)
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
	public func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Download.Response) -> Void) -> URLSessionBasedDownloadOperation {
		addCompletionHandler((block, queue))
		return self
	}
	
	@discardableResult
	public func addProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> URLSessionBasedDownloadOperation {
		addProgressHandler((block, queue))
		return self
	}
}

extension URLSessionBasedDownloadOperation: CustomStringConvertible {
	public var description: String {
		return "\(state), id=\(id), progress=\(numberOfBytesReceived) / \(totalNumberOfBytesToReceive), response=\(response as Any)"
	}
}
