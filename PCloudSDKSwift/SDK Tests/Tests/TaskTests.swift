//
//  TaskTests.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import XCTest
@testable import PCloudSDKSwift

final class CallTaskTests: XCTestCase {
	var operation: CallOperationMock!
	var task: CallTask<VoidApiMethod>!
	
	override func setUp() {
		super.setUp()
		
		operation = CallOperationMock()
		task = createTask(parser: { _ in })
	}
	
	func createTask(parser: @escaping ([String: Any]) throws -> Void) -> CallTask<VoidApiMethod> {
		return CallTask(operation: operation, responseParser: parser)
	}
	
	func testTaskCompletesWithSuccessWhenOperationCompletesWithSuccessAndParserDoesNotFail() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task.setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isSuccess, "incorrect task result; expected success; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .success([:]))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testTaskCompletesWithFailureWhenOperationCompletesWithFailure() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task.setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(NSError.void()))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testTaskCompletesWithFailureWhenOperationCompletesWithSuccessAndParserFails() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task = createTask(parser: { _ in
			throw NSError.void()
		})
		
		task.setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(NSError.void()))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testEnqueuesOperationOnStart() {
		// When
		task.start()
		
		// Expect
		XCTAssert(operation.enqueueInvoked, "operation should have been enqeued")
	}
	
	func testCancelsOperationOnCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(operation.cancelInvoked, "operation should have been cancelled")
		XCTAssert(task.isCancelled, "task should have its cancelled status updated")
	}
	
	func testTaskIsCancelledAfterCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(task.isCancelled, "task should be cancelled")
	}
}


final class UploadTaskTests: XCTestCase {
	var operation: UploadOperationMock!
	var task: UploadTask<VoidApiMethod>!
	
	override func setUp() {
		super.setUp()
		
		operation = UploadOperationMock()
		task = createTask(parser: { _ in })
	}
	
	func createTask(parser: @escaping ([String: Any]) throws -> Void) -> UploadTask<VoidApiMethod> {
		return UploadTask(operation: operation, responseParser: parser)
	}
	
	func testEnqueuesOperationOnStart() {
		// When
		task.start()
		
		// Expect
		XCTAssert(operation.enqueueInvoked, "operation should have been enqeued")
	}
	
	func testCancelsOperationOnCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(operation.cancelInvoked, "operation should have been cancelled")
		XCTAssert(task.isCancelled, "task should have its cancelled status updated")
	}
	
	func testTaskIsCancelledAfterCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(task.isCancelled, "task should be cancelled")
	}
	
	func testCompletesWithSuccessWhenOperationCompletesWithSuccessAndParserDoesNotFail() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task.setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isSuccess, "incorrect task result; expected success; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .success([:]))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCompletesWithFailureWhenOperationCompletesWithFailure() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task.setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(NSError.void()))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCompletesWithFailureWhenOperationCompletesWithSuccessAndParserFails() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task = createTask(parser: { _ in
			throw NSError.void()
		})
		
		task.setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(NSError.void()))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testInvokesProgressBlockWhenOperationProgresses() {
		let invokeExpectation = expectation(description: "to invoke progress block")
		
		// Given
		task.setProgressBlock { _,_  in
			// Expect
			invokeExpectation.fulfill()
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
		}
		
		// When
		operation.invokeProgress(sent: 0, total: 0)
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}


final class DownloadTaskTest: XCTestCase {
	var operation: DownloadOperationMock!
	
	override func setUp() {
		super.setUp()
		
		operation = DownloadOperationMock()
	}
	
	func createTask(addressProviderResult result: Result<URL>) -> DownloadTask {
		return DownloadTask(addressProvider: { complete in
			complete(result)
			return VoidCancellationToken()
		}, operationBuilder: { _ in
			return self.operation
		})
	}
	
	func testCompletesWithFailureWhenAddressProviderFails() {
		let invokeExpectation = expectation(description: "to invoke completion")
		
		// Given
		let task = createTask(addressProviderResult: .failure(NSError.void())).setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			XCTAssert(result.isFailure, "invalid download result; expected failure, got \(result)")
		}
		
		// When
		task.start()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCompletesWithFailureWhenDownloadFails() {
		let invokeExpectation = expectation(description: "to invoke completion")
		
		// Given
		let address = URL(string: "http://google.com")!
		let task = createTask(addressProviderResult: .success(address)).setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			XCTAssert(result.isFailure, "invalid download result; expected failure, got \(result)")
		}
		
		// When
		task.start()
		operation.invokeCompletion(response: .failure(NSError.void()))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCompletesWithSuccessWhenDownloadCompletesWithSuccess() {
		let invokeExpectation = expectation(description: "to invoke completion")
		
		// Given
		let address = URL(string: "http://google.com")!
		let task = createTask(addressProviderResult: .success(address)).setCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			XCTAssert(result.isSuccess, "invalid download result; expected success, got \(result)")
		}
		
		// When
		task.start()
		operation.invokeCompletion(response: .success(address))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testInvokesProgressBlockWhenDownloadProgresses() {
		let invokeExpectation = expectation(description: "to invoke progress block")
		
		// Given
		let address = URL(string: "http://google.com")!
		let task = createTask(addressProviderResult: .success(address)).setProgressBlock { _,_  in
			// Expect
			invokeExpectation.fulfill()
		}
		
		// When
		task.start()
		operation.invokeProgress(written: 0, total: 0)
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCancelsAddressProviderOnCancelDuringAddressProviding() {
		let invokeExpectation = expectation(description: "to invoke cancel on cancellation token")
		
		// Given
		let task = DownloadTask(addressProvider: { _ in
			return AnyCancellationToken {
				invokeExpectation.fulfill()
			}
		}, operationBuilder: { _ in
			return self.operation
		})
		
		// When
		task.start()
		task.cancel()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCancelsDownloadOperationOnCancelDuringDownload() {
		// Given
		let address = URL(string: "http://google.com")!
		let task = createTask(addressProviderResult: .success(address))
		
		// When
		task.start()
		task.cancel()
		
		// Expect
		XCTAssert(operation.isCancelled, "operation should have been cancelled")
	}
}


struct VoidApiMethod: PCloudApiMethod {
	var requiresAuthentication: Bool = false
	
	func createCommand() -> Call.Command {
		return Call.Command(name: "nop", parameters: [])
	}
	
	func createResponseParser() -> ([String : Any]) throws -> Void {
		return { _ in }
	}
}
