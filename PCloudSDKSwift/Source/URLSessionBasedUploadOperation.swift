//
//  URLSessionBasedUploadOperation.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Concrete implementation of `UploadOperation` backed by a `URLSessionUploadTask`.
public final class URLSessionBasedUploadOperation: URLSessionBasedNetworkOperation<Upload.Response> {
	/// Initializes an operation with a task.
	///
	/// - parameter task: A backing upload task in a suspended state.
	public init(task: URLSessionUploadTask) {
		super.init(task: task)
		
		// Assign callbacks.
		
		var responseData = Data()
		
		didReceiveData = { data in
			// Build response data.
			responseData.append(data)
		}
		
		didComplete = { [weak self] error in
			guard let me = self, !me.isCancelled else {
				return
			}
			
			// Compute response.
			let response: Upload.Response = {
				if let error = error {
					return .failure(.clientError(error))
				}
				
				do {
					let json = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
					return .success(json)
				} catch {
					return .failure(.clientError(error))
				}
			}()
			
			// Complete.
			me.taskResponse = response
			me.notifyCompletion(response: response)
		}
	}
}

extension URLSessionBasedUploadOperation: UploadOperation {
	public var response: Upload.Response? {
		return taskResponse
	}
	
	public var numberOfBytesSent: Int64 {
		return task.countOfBytesSent
	}
	
	public var totalNumberOfBytesToSend: Int64 {
		return task.countOfBytesExpectedToSend
	}
	
	@discardableResult
	public func setCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Upload.Response) -> Void) -> URLSessionBasedUploadOperation {
		completion = (block, queue)
		return self
	}
	
	@discardableResult
	public func setProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> URLSessionBasedUploadOperation {
		didSendBodyData = { sent, total in
			// Call the progress block on the main queue unless explicitly requested otherwise.
			(queue ?? .main).async {
				block(sent, total)
			}
		}
		
		return self
	}
}

extension URLSessionBasedUploadOperation: CustomStringConvertible {
	public var description: String {
		return "\(state), id=\(id), progress=\(numberOfBytesSent) / \(totalNumberOfBytesToSend), response=\(response as Any)"
	}
}
