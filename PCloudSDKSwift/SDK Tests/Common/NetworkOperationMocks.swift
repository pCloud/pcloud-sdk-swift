//
//  NetworkOperationMocks.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
@testable import PCloudSDKSwift

class NetworkOperationMock {
	var startInvoked = false
	var cancelInvoked = false
}

extension NetworkOperationMock: NetworkOperation {
	var id: Int {
		return 42
	}
	
	var state: NetworkOperationState {
		return .suspended
	}
	
	var isCancelled: Bool {
		return cancelInvoked
	}
	
	func start() {
		startInvoked = true
	}
	
	func cancel() {
		cancelInvoked = true
	}
}


class CallOperationMock: NetworkOperationMock {
	fileprivate(set) var completionBlocks: [((Call.Response) -> Void)] = []
	
	func invokeCompletion(response: Call.Response) {
		for block in completionBlocks {
			block(response)
		}
	}
}

extension CallOperationMock: CallOperation {
	var response: Call.Response? {
		return nil
	}
	
	@discardableResult
	func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Call.Response) -> Void) -> Self {
		completionBlocks.append(block)
		return self
	}
}


class UploadOperationMock: NetworkOperationMock {
	fileprivate(set) var completionBlocks: [((Upload.Response) -> Void)] = []
	fileprivate(set) var progressBlocks: [((Int64, Int64) -> Void)] = []
	
	func invokeCompletion(response: Upload.Response) {
		for block in completionBlocks {
			block(response)
		}
	}
	
	func invokeProgress(sent: Int64, total: Int64) {
		for block in progressBlocks {
			block(sent, total)
		}
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
	func addProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> Self {
		progressBlocks.append(block)
		return self
	}
	
	@discardableResult
	func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Upload.Response) -> Void) -> Self {
		completionBlocks.append(block)
		return self
	}
}


class DownloadOperationMock: NetworkOperationMock {
	fileprivate(set) var completionBlocks: [((Download.Response) -> Void)] = []
	fileprivate(set) var progressBlocks: [((Int64, Int64) -> Void)] = []
	
	func invokeCompletion(response: Download.Response) {
		for block in completionBlocks {
			block(response)
		}
	}
	
	func invokeProgress(written: Int64, total: Int64) {
		for block in progressBlocks {
			block(written, total)
		}
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
	func addProgressBlock(queue: DispatchQueue?, _ block: @escaping (Int64, Int64) -> Void) -> Self {
		progressBlocks.append(block)
		return self
	}
	
	@discardableResult
	func addCompletionBlock(queue: DispatchQueue?, _ block: @escaping (Download.Response) -> Void) -> Self {
		completionBlocks.append(block)
		return self
	}
}


