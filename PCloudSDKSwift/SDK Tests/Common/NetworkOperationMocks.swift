//
//  NetworkOperationMocks.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation
@testable import PCloudSDKSwift

class NetworkOperationMock {
	var enqueueInvoked = false
	var cancelInvoked = false
}

extension NetworkOperationMock: NetworkOperation {
	var id: String {
		return "42"
	}
	
	var state: NetworkOperationState {
		return .suspended
	}
	
	var isCancelled: Bool {
		return cancelInvoked
	}
	
	func enqueue() {
		enqueueInvoked = true
	}
	
	func cancel() {
		cancelInvoked = true
	}
}


class CallOperationMock: NetworkOperationMock {
	fileprivate(set) var completionBlock: ((Call.Response) -> Void)?
	
	func invokeCompletion(response: Call.Response) {
		completionBlock!(response)
	}
}

extension CallOperationMock: CallOperation {
	var response: Call.Response? {
		return nil
	}
	
	@discardableResult
	func setCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Call.Response) -> Void) -> Self {
		completionBlock = block
		return self
	}
}


class UploadOperationMock: NetworkOperationMock {
	fileprivate(set) var completionBlock: ((Upload.Response) -> Void)?
	fileprivate(set) var progressBlock: ((Int64, Int64) -> Void)?
	
	func invokeCompletion(response: Upload.Response) {
		completionBlock!(response)
	}
	
	func invokeProgress(sent: Int64, total: Int64) {
		progressBlock!(sent, total)
	}
}

extension UploadOperationMock: UploadOperation {
	var response: Upload.Response? {
		return nil
	}
	
	var numberOfBytesSent: Int64 {
		return 0
	}
	
	var totalNumberOfBytesToSend: Int64 {
		return 0
	}
	
	@discardableResult
	func setProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> Self {
		progressBlock = block
		return self
	}
	
	@discardableResult
	func setCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Upload.Response) -> Void) -> Self {
		completionBlock = block
		return self
	}
}


class DownloadOperationMock: NetworkOperationMock {
	fileprivate(set) var completionBlock: ((Download.Response) -> Void)?
	fileprivate(set) var progressBlock: ((Int64, Int64) -> Void)?
	
	func invokeCompletion(response: Download.Response) {
		completionBlock!(response)
	}
	
	func invokeProgress(written: Int64, total: Int64) {
		progressBlock!(written, total)
	}
}

extension DownloadOperationMock: DownloadOperation {
	var response: Download.Response? {
		return nil
	}
	
	var numberOfBytesReceived: Int64 {
		return 0
	}
	
	var totalNumberOfBytesToReceive: Int64 {
		return 0
	}
	
	@discardableResult
	func setProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> Self {
		progressBlock = block
		return self
	}
	
	@discardableResult
	func setCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Download.Response) -> Void) -> Self {
		completionBlock = block
		return self
	}
}


