//
//  URLSessionBasedCallOperation.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Concrete implementation of `CallOperation` backed by a `URLSessionDataTask`.
public final class URLSessionBasedCallOperation: URLSessionBasedNetworkOperation<Call.Response> {
	/// Initializes an operation with a task.
	///
	/// - parameter task: A backing data task in a suspended state.
	public init(task: URLSessionDataTask) {
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
			let response: Call.Response = {
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
			me.complete(response: response)
		}
	}
}


extension URLSessionBasedCallOperation: CallOperation {
	public var response: Call.Response? {
		return taskResponse
	}
	
	@discardableResult
	public func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Call.Response) -> Void) -> URLSessionBasedCallOperation {
		addCompletionHandler((block, queue))
		return self
	}
}

extension URLSessionBasedCallOperation: CustomStringConvertible {
	public var description: String {
		return "\(state), id=\(id), response=\(response as Any)"
	}
}
