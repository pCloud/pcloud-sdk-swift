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
	var task: CallTask<VoidAPIMethod>!
	
	override func setUp() {
		super.setUp()
		
		operation = CallOperationMock()
		task = createTask(parser: { _ in .success(()) })
	}
	
	func createTask(parser: @escaping ([String: Any]) throws -> Result<VoidAPIMethod.Value, PCloudAPI.Error<VoidAPIMethod.Error>>) -> CallTask<VoidAPIMethod> {
		return CallTask(operation: operation, responseParser: parser)
	}
	
	func testTaskCompletesWithSuccessWhenOperationCompletesWithSuccessAndParserDoesNotFail() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task.addCompletionBlock { result in
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
		task.addCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(.clientError(NSError.void())))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testTaskCompletesWithFailureWhenOperationCompletesWithSuccessAndParserFails() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task = createTask(parser: { _ in
			throw NSError.void()
		})
		
		task.addCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(.clientError(NSError.void())))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testStartsOperationOnStart() {
		// When
		task.start()
		
		// Expect
		XCTAssert(operation.startInvoked, "operation should have been started")
	}
	
	func testCancelsOperationOnCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(operation.cancelInvoked, "operation should have been cancelled")
		XCTAssert(task.isCancelled, "task should have its cancelled status updated")
	}
}


final class UploadTaskTests: XCTestCase {
	var operation: UploadOperationMock!
	var task: UploadTask<VoidAPIMethod>!
	
	override func setUp() {
		super.setUp()
		
		operation = UploadOperationMock()
		task = createTask(parser: { _ in .success(()) })
	}
	
	func createTask(parser: @escaping ([String: Any]) throws -> Result<VoidAPIMethod.Value, PCloudAPI.Error<VoidAPIMethod.Error>>) -> UploadTask<VoidAPIMethod> {
		return UploadTask(operation: operation, responseParser: parser)
	}
	
	func testStartsOperationOnStart() {
		// When
		task.start()
		
		// Expect
		XCTAssert(operation.startInvoked, "operation should have been started")
	}
	
	func testCancelsOperationOnCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(operation.cancelInvoked, "operation should have been cancelled")
		XCTAssert(task.isCancelled, "task should have its cancelled status updated")
	}
	
	func testCompletesWithSuccessWhenOperationCompletesWithSuccessAndParserDoesNotFail() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task.addCompletionBlock { result in
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
		task.addCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(.clientError(NSError.void())))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCompletesWithFailureWhenOperationCompletesWithSuccessAndParserFails() {
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// Given
		task = createTask(parser: { _ in
			throw NSError.void()
		})
		
		task.addCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			
			XCTAssert(Thread.isMainThread, "expected block to be invoked on the main thread")
			XCTAssert(result.isFailure, "incorrect task result; expected failure; got \(result)")
		}
		
		// When
		operation.invokeCompletion(response: .failure(.clientError(NSError.void())))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testInvokesProgressBlockWhenOperationProgresses() {
		let invokeExpectation = expectation(description: "to invoke progress block")
		
		// Given
		task.addProgressBlock { _,_  in
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
	var task: DownloadTask!
	
	override func setUp() {
		super.setUp()
		
		operation = DownloadOperationMock()
		task = DownloadTask(operation: operation)
	}
	
	func testStartsOperationOnStart() {
		// When
		task.start()
		
		// Expect
		XCTAssert(operation.startInvoked, "operation should have been started")
	}
	
	func testCancelsOperationOnCancel() {
		// When
		task.cancel()
		
		// Expect
		XCTAssert(operation.cancelInvoked, "operation should have been cancelled")
	}
	
	func testCompletesWithSuccessWhenDownloadSucceeds() {
		let invokeExpectation = expectation(description: "to call completion block")
		
		task.addCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			XCTAssert(Thread.isMainThread, "block should be called on the main thread")
			XCTAssert(result.isSuccess, "download task should succeed when operation succeeds")
		}
		
		// When
		task.start()
		operation.invokeCompletion(response: .success(URL(fileURLWithPath: "/dev/null")))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCompletesWithFailureWhenDownloadFails() {
		let invokeExpectation = expectation(description: "to invoke completion")
		
		task.addCompletionBlock { result in
			// Expect
			invokeExpectation.fulfill()
			XCTAssert(Thread.isMainThread, "block should be called on the main thread")
			XCTAssert(result.isFailure, "invalid download result; expected failure, got \(result)")
		}
		
		// When
		task.start()
		operation.invokeCompletion(response: .failure(.clientError(NSError.void())))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testInvokesProgressBlockWhenDownloadProgresses() {
		let invokeExpectation = expectation(description: "to invoke progress block")
		
		task.addProgressBlock { _,_  in
			// Expect
			invokeExpectation.fulfill()
		}
		
		// When
		task.start()
		operation.invokeProgress(written: 0, total: 0)
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}


struct VoidAPIMethod: PCloudAPIMethod {
	var requiresAuthentication: Bool = false
	
	func createCommand() -> Call.Command {
		return Call.Command(name: "nop", parameters: [])
	}
	
	func createResponseParser() -> ([String : Any]) throws -> Result<Void, PCloudAPI.Error<NullError>> {
		return { _ in .success(()) }
	}
}
