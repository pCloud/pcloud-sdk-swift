//
//  URLSessionBasedOperationsTests.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import XCTest
@testable import PCloudSDKSwift

final class URLSessionBasedCallOperationTests: XCTestCase, URLSessionBasedOperationTestCase {
	var session: URLSession!
	
	override func setUp() {
		super.setUp()
		
		session = URLSession(configuration: .default)
	}
	
	override func tearDown() {
		session.invalidateAndCancel()
		
		super.tearDown()
	}
	
	func createOperation() -> URLSessionBasedCallOperation {
		return URLSessionBasedCallOperation(task: createDataTask(session: session))
	}
	
	func testInvokesCallbackBlockOnDidSendBodyData() {
		testInvokesCallbackBlockOnDidSendBodyData(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled() {
		testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidReceiveData() {
		testInvokesCallbackBlockOnDidReceiveData(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidFinishDownloading() {
		testInvokesCallbackBlockOnDidFinishDownloading(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidWriteData() {
		testInvokesCallbackBlockOnDidWriteData(session: session, operation: createOperation())
	}
	
	func test_completeOperationWithData_expectItAssignsSuccessResult() {
		// Given
		let operation = createOperation()
		let responseData = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
		let task = createDataTask(session: session)
		
		// When
		operation.urlSession(session, dataTask: task, didReceive: responseData)
		operation.urlSession(session, task: task, didCompleteWithError: nil)
		
		// Expect
		guard let response = operation.response else {
			XCTFail("operation should assign a result when finished")
			return
		}
		
		XCTAssert(response.isSuccess, "operation should assign succesful result; got \(response)")
	}
	
	func test_completeOperationWithError_expectItAssignsResult() {
		// Given
		let operation = createOperation()
		let error = NSError(domain: "holy shit", code: 1, userInfo: nil)
		let task = createDataTask(session: session)
		
		// When
		operation.urlSession(session, task: task, didCompleteWithError: error)
		
		// Expect
		guard let response = operation.response else {
			XCTFail("operation should assign a result when finished")
			return
		}
		
		XCTAssert(response.isFailure, "operation should assign a failure result; got \(response)")
	}
	
	func test_completeOperationWithData_expectItInvokesItsCompletionBlock() {
		// Given
		let operation = createOperation()
		let responseData = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
		let task = createDataTask(session: session)
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		operation.setCompletionBlock(queue: .main) { _ in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, dataTask: task, didReceive: responseData)
		operation.urlSession(session, task: task, didCompleteWithError: nil)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func test_completeOperationWithError_expectItInvokesItsCompletionBlock() {
		// Given
		let operation = createOperation()
		let error = NSError(domain: "holy shit", code: 1, userInfo: nil)
		let task = createDataTask(session: session)
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		operation.setCompletionBlock(queue: .main) { _ in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, task: task, didCompleteWithError: error)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
}


final class URLSessionBasedUploadOperationTests: XCTestCase, URLSessionBasedOperationTestCase {
	var session: URLSession!
	
	override func setUp() {
		super.setUp()
		
		session = URLSession(configuration: .default)
	}
	
	override func tearDown() {
		session.invalidateAndCancel()
		
		super.tearDown()
	}
	
	func createOperation() -> URLSessionBasedUploadOperation {
		return URLSessionBasedUploadOperation(task: createUploadTask(session: session))
	}
	
	func testInvokesCallbackBlockOnDidSendBodyData() {
		testInvokesCallbackBlockOnDidSendBodyData(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled() {
		testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidReceiveData() {
		testInvokesCallbackBlockOnDidReceiveData(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidFinishDownloading() {
		testInvokesCallbackBlockOnDidFinishDownloading(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidWriteData() {
		testInvokesCallbackBlockOnDidWriteData(session: session, operation: createOperation())
	}
	
	func test_progressOperation_expectItInvokesItsProgressBlock() {
		// Given
		let operation = createOperation()
		let task = createDataTask(session: session)
		let invokeExpectation = expectation(description: "to invoke progress block")
		
		operation.setProgressBlock(queue: .main) { _,_  in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, task: task, didSendBodyData: 0, totalBytesSent: 0, totalBytesExpectedToSend: 0)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func test_completeOperationWithData_expectItAssignsSuccessResult() {
		// Given
		let operation = createOperation()
		let responseData = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
		let task = createDataTask(session: session)
		
		// When
		operation.urlSession(session, dataTask: task, didReceive: responseData)
		operation.urlSession(session, task: task, didCompleteWithError: nil)
		
		// Expect
		guard let response = operation.response else {
			XCTFail("operation should assign a result when finished")
			return
		}
		
		XCTAssert(response.isSuccess, "operation should assign succesful result; got \(response)")
	}
	
	func test_completeOperationWithError_expectItAssignsResult() {
		// Given
		let operation = createOperation()
		let error = NSError(domain: "holy shit", code: 1, userInfo: nil)
		let task = createDataTask(session: session)
		
		// When
		operation.urlSession(session, task: task, didCompleteWithError: error)
		
		// Expect
		guard let response = operation.response else {
			XCTFail("operation should assign a result when finished")
			return
		}
		
		XCTAssert(response.isFailure, "operation should assign a failure result; got \(response)")
	}
	
	func test_completeOperationWithData_expectItInvokesItsCompletionBlock() {
		// Given
		let operation = createOperation()
		let responseData = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
		let task = createDataTask(session: session)
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		operation.setCompletionBlock(queue: .main) { _ in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, dataTask: task, didReceive: responseData)
		operation.urlSession(session, task: task, didCompleteWithError: nil)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func test_completeOperationWithError_expectItInvokesItsCompletionBlock() {
		// Given
		let operation = createOperation()
		let error = NSError(domain: "holy shit", code: 1, userInfo: nil)
		let task = createDataTask(session: session)
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		operation.setCompletionBlock(queue: .main) { _ in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, task: task, didCompleteWithError: error)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
}


final class URLSessionBasedDownloadOperationTests: XCTestCase, URLSessionBasedOperationTestCase {
	var session: URLSession!
	
	override func setUp() {
		super.setUp()
		
		session = URLSession(configuration: .default)
	}
	
	override func tearDown() {
		session.invalidateAndCancel()
		removeFile(at: downloadFilePath())
		removeFile(at: defaultDestinationFilePath())
		
		super.tearDown()
	}
	
	func defaultDestinationFilePath() -> URL {
		return URL(fileURLWithPath: NSTemporaryDirectory() + "com.URLSessionBasedDownloadOperationTests.destination.tmp")
	}
	
	func downloadFilePath() -> URL {
		return URL(fileURLWithPath: NSTemporaryDirectory() + "com.URLSessionBasedDownloadOperationTests.download.tmp")
	}
	
	func createFile(at path: URL) {
		FileManager.default.createFile(atPath: path.path, contents: "test data".data(using: .utf8), attributes: nil)
	}
	
	func removeFile(at path: URL) {
		guard FileManager.default.fileExists(atPath: path.path) else {
			return
		}
		
		do {
			try FileManager.default.removeItem(at: path)
		} catch {
			print("Could not delete file at path \(path); error is \(error)")
		}
	}
	
	func createOperation(destinationBlock: @escaping (URL) throws -> URL) -> URLSessionBasedDownloadOperation {
		return URLSessionBasedDownloadOperation(task: createDownloadTask(session: session), destination: destinationBlock)
	}
	
	func createOperation(destination: URL? = nil) -> URLSessionBasedDownloadOperation {
		let destination = destination ?? defaultDestinationFilePath()
		return URLSessionBasedDownloadOperation(task: createDownloadTask(session: session)) { _ in return destination }
	}
	
	func validateResponse(in operation: URLSessionBasedDownloadOperation, against expected: Download.Response) {
		guard let response = operation.response else {
			XCTFail("expected response assigned to operation")
			return
		}
		
		if !response.shallowEquals(expected) {
			XCTFail("invalid operation response; expected \(expected), got \(response)")
		}
	}
	
	func testInvokesCallbackBlockOnDidSendBodyData() {
		testInvokesCallbackBlockOnDidSendBodyData(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled() {
		testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidReceiveData() {
		testInvokesCallbackBlockOnDidReceiveData(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidFinishDownloading() {
		testInvokesCallbackBlockOnDidFinishDownloading(session: session, operation: createOperation())
	}
	
	func testInvokesCallbackBlockOnDidWriteData() {
		testInvokesCallbackBlockOnDidWriteData(session: session, operation: createOperation())
	}
	
	func test_progressOperation_expectItInvokesItsProgressBlock() {
		// Given
		let operation = createOperation()
		let task = createDownloadTask(session: session)
		let invokeExpectation = expectation(description: "to invoke progress block")
		
		operation.setProgressBlock(queue: .main) { _,_  in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, downloadTask: task, didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 0)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func test_completeOperationWithError_expectOperationAssignsFailureResult() {
		// Given
		let operation = createOperation()
		let task = createDownloadTask(session: session)
		
		// When
		operation.urlSession(session, task: task, didCompleteWithError: NSError.void())
		
		// Expect
		validateResponse(in: operation, against: .failure(.clientError(NSError.void())))
	}
	
	func test_completeOperationWithFile_expectItInvokesItsCompletionBlock() {
		// Given
		let operation = createOperation()
		let task = createDownloadTask(session: session)
		createFile(at: downloadFilePath())
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		operation.setCompletionBlock(queue: .main) { _ in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, downloadTask: task, didFinishDownloadingTo: downloadFilePath())
		operation.urlSession(session, task: task, didCompleteWithError: nil)
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func test_completeOperationWithError_expectItInvokesItsCompletionBlock() {
		// Given
		let operation = createOperation()
		let task = createDownloadTask(session: session)
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		operation.setCompletionBlock(queue: .main) { _ in
			invokeExpectation.fulfill()
		}
		
		// When
		operation.urlSession(session, task: task, didCompleteWithError: NSError.void())
		
		// Expect
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func test_onDidFinishDownloading_expectOperationToCallDestinationBlock() {
		// Given
		let invokeExpectation = expectation(description: "to invoke destination block")
		let operation = createOperation(destinationBlock: { path in
			// Expect
			invokeExpectation.fulfill()
			return path
		})
		
		let task = createDownloadTask(session: session)
		
		// When
		operation.urlSession(session, downloadTask: task, didFinishDownloadingTo: downloadFilePath())
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}


protocol URLSessionBasedOperationTestCase {
}

extension URLSessionBasedOperationTestCase {
	func createDataTask(session: URLSession) -> URLSessionDataTask {
		return session.dataTask(with: URL(string: "http://google.com")!)
	}
	
	func createUploadTask(session: URLSession) -> URLSessionUploadTask {
		return session.uploadTask(with: URLRequest(url: URL(string: "http://google.com")!), from: "something to upload".data(using: .utf8)!)
	}
	
	func createDownloadTask(session: URLSession) -> URLSessionDownloadTask {
		return session.downloadTask(with: URL(string: "http://google.com")!)
	}
	
	func testInvokesCallbackBlockOnDidSendBodyData<T>(session: URLSession, operation: URLSessionBasedNetworkOperation<T>) {
		// Given
		var invoked = false
		operation.didSendBodyData = { _, _ in invoked = true }
		
		// When
		operation.urlSession(session, task: createDataTask(session: session), didSendBodyData: 0, totalBytesSent: 0, totalBytesExpectedToSend: 0)
		
		// Expect
		XCTAssert(invoked, "should invoke callback")
	}
	
	func testInvokesCallbackBlockOnDidCompleteWithErrorWhenNotCancelled<T>(session: URLSession, operation: URLSessionBasedNetworkOperation<T>) {
		// Given
		var invoked = false
		operation.didComplete = { _ in invoked = true }
		
		// When
		operation.urlSession(session, task: createDataTask(session: session), didCompleteWithError: nil)
		
		// Expect
		XCTAssert(invoked, "should invoke callback")
	}
	
	func testInvokesCallbackBlockOnDidReceiveData<T>(session: URLSession, operation: URLSessionBasedNetworkOperation<T>) {
		// Given
		var invoked = false
		operation.didReceiveData = { _ in invoked = true }
		
		// When
		operation.urlSession(session, dataTask: createDataTask(session: session), didReceive: Data())
		
		// Expect
		XCTAssert(invoked, "should invoke callback")
	}
	
	func testInvokesCallbackBlockOnDidFinishDownloading<T>(session: URLSession, operation: URLSessionBasedNetworkOperation<T>) {
		// Given
		var invoked = false
		operation.didFinishDownloading = { _ in invoked = true }
		
		// When
		operation.urlSession(session, downloadTask: createDownloadTask(session: session), didFinishDownloadingTo: URL(fileURLWithPath: "/"))
		
		// Expect
		XCTAssert(invoked, "should invoke callback")
	}
	
	func testInvokesCallbackBlockOnDidWriteData<T>(session: URLSession, operation: URLSessionBasedNetworkOperation<T>) {
		// Given
		var invoked = false
		operation.didWriteData = { _, _ in invoked = true }
		
		// When
		operation.urlSession(session, downloadTask: createDownloadTask(session: session), didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 0)
		
		// Expect
		XCTAssert(invoked, "should invoke callback")
	}
}
