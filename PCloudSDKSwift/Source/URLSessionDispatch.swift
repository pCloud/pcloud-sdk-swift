//
//  URLSessionDispatch.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Contains logic for building `URLSessionTask`-backed network operations from network requests.
public struct URLSessionDispatch {
	/// Creates and returns a block that builds a `CallOperation` from a `Call.Request` using a `URLSession`.
	///
	/// - parameter scheme: A scheme to use when building the operation.
	/// - parameter session: A session used to create data tasks.
	/// - parameter delegate: The session delegate.
	/// - returns: A block that builds a `URLSessionDataTask`-backed `CallOperation` from a `Call.Request`.
	public static func callOperationBuilder(scheme: Scheme, session: URLSession, delegate: URLSessionEventHub) -> (Call.Request) -> CallOperation {
		return { request in
			let task = URLSessionTaskBuilder.createDataTask(request: request, session: session, scheme: scheme)
			let operation = URLSessionBasedCallOperation(task: task)
			delegate.setObserver(operation, for: task)
			
			return operation
		}
	}
	
	/// Creates and returns a block that builds an `UploadOperation` from an `Upload.Request` using a `URLSession`.
	///
	/// - parameter scheme: A scheme to use when building the operation.
	/// - parameter session: A session used to create upload tasks.
	/// - parameter delegate: The session delegate.
	/// - returns: A block that builds a `URLSessionUploadTask`-backed `UploadOperation` from an `Upload.Request`.
	public static func uploadOperationBuilder(scheme: Scheme, session: URLSession, delegate: URLSessionEventHub) -> (Upload.Request) -> UploadOperation {
		return { request in
			let task = URLSessionTaskBuilder.createUploadTask(request: request, session: session, scheme: scheme)
			let operation = URLSessionBasedUploadOperation(task: task)
			delegate.setObserver(operation, for: task)
			
			return operation
		}
	}
	
	/// Creates and returns a block that builds a `DownloadOperation` from a `Download.Request` using a `URLSession`.
	///
	/// - parameter session: A session used to create download tasks.
	/// - parameter delegate: The session delegate.
	/// - returns: A block that builds a `URLSessionDownloadTask`-backed `DownloadOperation` from a `Download.Request`.
	public static func downloadOperationBuilder(session: URLSession, delegate: URLSessionEventHub) -> (Download.Request) -> DownloadOperation {
		return { request in
			let task = URLSessionTaskBuilder.createDownloadTask(request: request, session: session)
			let operation = URLSessionBasedDownloadOperation(task: task, destination: request.destination)
			delegate.setObserver(operation, for: task)
			
			return operation
		}
	}
}
