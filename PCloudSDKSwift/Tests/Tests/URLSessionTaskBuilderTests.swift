//
//  URLSessionTaskBuilderTests.swift
//  SDK Tests
//
//  Created by Todor Pitekov on 5.03.20.
//  Copyright © 2020 pCloud LTD. All rights reserved.
//

import XCTest
import PCloudSDKSwift

final class URLSessionTaskBuilderTests: XCTestCase {
	private var session: URLSession!
	
	override func setUp() {
		super.setUp()
		
		session = URLSession(configuration: .ephemeral)
	}
	
	override func tearDown() {
		session = nil
		
		super.tearDown()
	}
	
	func testBuilderPercentEncodesQueryForDataTask() {
		// Given
		let method = PCloudAPI.CreateFolder(name: "my fancy&new+folder@", parentFolderId: 0)
		
		// When
		let request = createDataTask(with: method).originalRequest!
		
		// Expect
		let queryString = String(bytes: request.httpBody!, encoding: .utf8)!
		let query = createDictionary(fromQueryString: queryString)
		
		XCTAssertEqual(query["name"], "my%20fancy%26new%2Bfolder%40", "data task query is not percent encoded or percent encoding is incorrect")
	}
	
	func testBuilderPercentEncodesQueryForUploadTask() {
		// Given
		let method = PCloudAPI.UploadFile(name: "my fancy&new+file@.txt", parentFolderId: 0, modificationDate: nil)
		
		// When
		let url = createUploadTask(with: method).originalRequest!.url!
		
		// Expect
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			XCTFail("incorrect upload task url: \"\(url)\"")
			return
		}
		
		let queryString = components.percentEncodedQuery!
		let query = createDictionary(fromQueryString: queryString)
		
		XCTAssertEqual(query["filename"], "my%20fancy%26new%2Bfile%40.txt", "upload task query is not percent encoded or percent encoding is incorrect")
	}
	
	private func createUploadTask<Method: PCloudAPIMethod>(with method: Method) -> URLSessionUploadTask {
		let command = method.createCommand()
		let body = Upload.Request.Body.data("texty text".data(using: .utf8)!)
		let request = Upload.Request(command: command, body: body, hostName: "api.pcloud.com")
		return URLSessionTaskBuilder.createUploadTask(with: request, session: session, scheme: .http)
	}
	
	private func createDataTask<Method: PCloudAPIMethod>(with method: Method) -> URLSessionDataTask {
		let command = method.createCommand()
		let request = Call.Request(command: command, hostName: "api.pcloud.com")
		return URLSessionTaskBuilder.createDataTask(with: request, session: session, scheme: .http)
	}
	
	private func createDictionary(fromQueryString query: String) -> [String: String?] {
		let pairs = query.components(separatedBy: "&")
		
		let entries: [(String, String?)] = pairs.map {
			let components = $0.components(separatedBy: "=")
			return (components.first!, components.last)
		}
		
		return Dictionary(uniqueKeysWithValues: entries)
	}
}
