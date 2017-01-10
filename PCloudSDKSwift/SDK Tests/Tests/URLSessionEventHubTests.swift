//
//  URLSessionEventHubTests.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import XCTest
@testable import PCloudSDKSwift


final class URLSessionEventHubTests: XCTestCase {
	var session: URLSession!
	var hub: URLSessionEventHub!
	
	override func setUp() {
		super.setUp()
		session = URLSession(configuration: URLSessionConfiguration.default)
		hub = URLSessionEventHub()
	}
	
	func createDataTask() -> URLSessionDataTask {
		return session.dataTask(with: URL(string: "http://google.com")!)
	}
	
	func createDownloadTask() -> URLSessionDownloadTask {
		return session.downloadTask(with: URL(string: "http://google.com")!)
	}
	
	func testNotifiesObserverOnDidSendBodyData() {
		// Given
		let spy = EventHubSpy()
		let task = createDataTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.urlSession(session, task: task, didSendBodyData: 0, totalBytesSent: 0, totalBytesExpectedToSend: 0)
		
		// Expect
		XCTAssert(spy.didSendBodyDataCalled, "did not invoke callback")
	}
	
	func testNotifiesObserverOnDidCompleteWithError() {
		// Given
		let spy = EventHubSpy()
		let task = createDataTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.urlSession(session, task: task, didCompleteWithError: nil)
		
		// Expect
		XCTAssert(spy.didCompleteWithErrorCalled, "did not invoke callback")
	}
	
	func testNotifiesObserverOnDidReceiveData() {
		// Given
		let spy = EventHubSpy()
		let task = createDataTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.urlSession(session, dataTask: task, didReceive: Data())
		
		// Expect
		XCTAssert(spy.didReceiveDataCalled, "did not invoke callback")
	}
	
	func testNotifiesObserverOnDidFinishDownloading() {
		// Given
		let spy = EventHubSpy()
		let task = createDownloadTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.urlSession(session, downloadTask: task, didFinishDownloadingTo: URL(fileURLWithPath: "/"))
		
		// Expect
		XCTAssert(spy.didFinishDownloadingCalled, "did not invoke callback")
	}
	
	func testNotifiesObserverOnDidWriteData() {
		// Given
		let spy = EventHubSpy()
		let task = createDownloadTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.urlSession(session, downloadTask: task, didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 0)
		
		// Expect
		XCTAssert(spy.didWriteDataCalled, "did not invoke callback")
	}
	
	func testDoesNotNotifyObserverAfterObserverIsRemoved() {
		// Given
		let spy = EventHubSpy()
		let task = createDataTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.removeObserver(for: task)
		hub.urlSession(session, dataTask: task, didReceive: Data())
		
		// Expect
		XCTAssert(!spy.didReceiveDataCalled, "should not invoke callback")
	}
	
	func testRemovesObserverOnDidCompleteWithError() {
		// Given
		let spy = EventHubSpy()
		let task = createDataTask()
		hub.setObserver(spy, for: task)
		
		// When
		hub.urlSession(session, task: task, didCompleteWithError: nil)
		hub.urlSession(session, dataTask: task, didReceive: Data())
		
		// Expect
		XCTAssert(!spy.didReceiveDataCalled, "should not invoke callback")
	}
}




final class EventHubSpy {
	fileprivate(set) var didSendBodyDataCalled = false
	fileprivate(set) var didCompleteWithErrorCalled = false
	fileprivate(set) var didReceiveDataCalled = false
	fileprivate(set) var didFinishDownloadingCalled = false
	fileprivate(set) var didWriteDataCalled = false
}

extension EventHubSpy: URLSessionObserver {
	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		didSendBodyDataCalled = true
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		didCompleteWithErrorCalled = true
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		didReceiveDataCalled = true
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		didFinishDownloadingCalled = true
	}
	
	func urlSession(_ session: URLSession,
	                downloadTask: URLSessionDownloadTask,
	                didWriteData bytesWritten: Int64,
	                totalBytesWritten: Int64,
	                totalBytesExpectedToWrite: Int64) {
		didWriteDataCalled = true
	}
}
