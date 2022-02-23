//
//  APITaskBuildingTests.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import XCTest
@testable import PCloudSDKSwift


final class PCloudAPICallTaskBuilderTests: XCTestCase {
	var builder: PCloudAPICallTaskBuilder!
	var dispatcher: OperationDispatcher!
	var authenticator: AuthenticatorMock!
	var hostProvider: HostProviderMock!
	
	override func setUp() {
		super.setUp()
		
		dispatcher = OperationDispatcher()
		
		authenticator = AuthenticatorMock()
		authenticator.authenticationParameters = [.string(name: "What's the password, member?", value: "Yeah, I member!")]
		
		hostProvider = HostProviderMock()
		hostProvider.defaultHostName = "domain.com"
		
		builder = PCloudAPICallTaskBuilder(hostProvider: hostProvider,
										   authenticator: authenticator,
										   defaultTimeoutInterval: nil,
										   operationBuilder: dispatcher.callOperation)
	}
	
	func testAuthenticatesMethodRequiringAuthentication() {
		// Given
		var method = VoidAPIMethod()
		method.requiresAuthentication = true
		
		// When
		_ = builder.createTask(for: method)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).isSuperset(of: Set(authenticator.authenticationParameters)), "call command should be authenticated")
	}
	
	func testDoesNotAuthenticateMethodNotRequiringAuthentication() {
		// Given
		var method = VoidAPIMethod()
		method.requiresAuthentication = false
		
		// When
		_ = builder.createTask(for: method)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).intersection(Set(authenticator.authenticationParameters)).isEmpty, "call command should not be authenticated")
	}
	
	func testFallsBackToDefaultHostNameWhenHostNameIsNotOverridden() {
		// Given
		let method = VoidAPIMethod()
		
		// When
		_ = builder.createTask(for: method, hostNameOverride: nil, timeoutInterval: nil)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(request.hostName == hostProvider.defaultHostName, "not falling back to default host name when host name is not overridden")
	}
	
	func testRespectsHostNameOverride() {
		// Given
		let method = VoidAPIMethod()
		let hostNameOverride = "another.domain.com"
		
		// When
		_ = builder.createTask(for: method, hostNameOverride: hostNameOverride, timeoutInterval: nil)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(request.hostName == hostNameOverride, "not respecting the host name override")
	}
	
	func testFallsBackToDefaultTimeoutIntervalWhenTimeoutIntervalIsNotProvided() {
		// Given
		let method = VoidAPIMethod()
		let defaultTimeoutInterval: TimeInterval = 30
		builder = PCloudAPICallTaskBuilder(hostProvider: hostProvider,
										   authenticator: authenticator,
										   defaultTimeoutInterval: defaultTimeoutInterval,
										   operationBuilder: dispatcher.callOperation)
		
		// When
		_ = builder.createTask(for: method, hostNameOverride: nil, timeoutInterval: nil)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(request.timeoutInterval == defaultTimeoutInterval, "not falling back to default timeout interval when timeout interval is not specified")
	}
	
	func testRespectsTimeoutInterval() {
		// Given
		let method = VoidAPIMethod()
		let taskTimeoutInterval: TimeInterval = 10
		builder = PCloudAPICallTaskBuilder(hostProvider: hostProvider,
										   authenticator: authenticator,
										   defaultTimeoutInterval: 30,
										   operationBuilder: dispatcher.callOperation)
		
		// When
		_ = builder.createTask(for: method, hostNameOverride: nil, timeoutInterval: taskTimeoutInterval)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(request.timeoutInterval == taskTimeoutInterval, "not respecting timeout interval")
	}
}


final class PCloudAPIUploadTaskBuilderTests: XCTestCase {
	var builder: PCloudAPIUploadTaskBuilder!
	var dispatcher: OperationDispatcher!
	var authenticator: AuthenticatorMock!
	var hostProvider: HostProviderMock!
	
	override func setUp() {
		super.setUp()
		
		dispatcher = OperationDispatcher()
		
		authenticator = AuthenticatorMock()
		authenticator.authenticationParameters = [.string(name: "What's the password, member?", value: "Yeah, I member!")]
		
		hostProvider = HostProviderMock()
		hostProvider.defaultHostName = "domain.com"
		
		builder = PCloudAPIUploadTaskBuilder(hostProvider: hostProvider,
											 authenticator: authenticator,
											 defaultTimeoutInterval: nil,
											 operationBuilder: dispatcher.uploadOperation)
	}
	
	func testAuthenticatesMethodRequiringAuthentication() {
		// Given
		var method = VoidAPIMethod()
		method.requiresAuthentication = true
		
		// When
		_ = builder.createTask(for: method, with: .data(Data()))
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).isSuperset(of: Set(authenticator.authenticationParameters)), "upload command should be authenticated")
	}
	
	func testDoesNotAuthenticateMethodNotRequiringAuthentication() {
		// Given
		var method = VoidAPIMethod()
		method.requiresAuthentication = false
		
		// When
		_ = builder.createTask(for: method, with: .data(Data()))
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).intersection(Set(authenticator.authenticationParameters)).isEmpty, "upload command should not be authenticated")
	}
	
	func testFallsBackToDefaultHostNameWhenHostNameIsNotOverridden() {
		// Given
		let method = VoidAPIMethod()
		
		// When
		_ = builder.createTask(for: method, with: .data(Data()), hostNameOverride: nil, timeoutInterval: nil)
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(request.hostName == hostProvider.defaultHostName, "not falling back to default host name when host name is not overridden")
	}
	
	func testRespectsHostNameOverride() {
		// Given
		let method = VoidAPIMethod()
		let hostNameOverride = "another.domain.com"
		
		// When
		_ = builder.createTask(for: method, with: .data(Data()), hostNameOverride: hostNameOverride, timeoutInterval: nil)
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(request.hostName == hostNameOverride, "not respecting the host name override")
	}
	
	func testFallsBackToDefaultTimeoutIntervalWhenTimeoutIntervalIsNotProvided() {
		// Given
		let method = VoidAPIMethod()
		let defaultTimeoutInterval: TimeInterval = 30
		builder = PCloudAPIUploadTaskBuilder(hostProvider: hostProvider,
											 authenticator: authenticator,
											 defaultTimeoutInterval: defaultTimeoutInterval,
											 operationBuilder: dispatcher.uploadOperation)
		
		// When
		_ = builder.createTask(for: method, with: .data(Data()), hostNameOverride: nil, timeoutInterval: nil)
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(request.timeoutInterval == defaultTimeoutInterval, "not falling back to default timeout interval when timeout interval is not specified")
	}
	
	func testRespectsTimeoutInterval() {
		// Given
		let method = VoidAPIMethod()
		let taskTimeoutInterval: TimeInterval = 10
		builder = PCloudAPIUploadTaskBuilder(hostProvider: hostProvider,
											 authenticator: authenticator,
											 defaultTimeoutInterval: 30,
											 operationBuilder: dispatcher.uploadOperation)
		
		// When
		_ = builder.createTask(for: method, with: .data(Data()), hostNameOverride: nil, timeoutInterval: taskTimeoutInterval)
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(request.timeoutInterval == taskTimeoutInterval, "not respecting timeout interval")
	}
}


final class PCloudAPIDownloadTaskBuilderTests: XCTestCase {
	var builder: PCloudAPIDownloadTaskBuilder!
	var dispatcher: OperationDispatcher!
	var authenticator: AuthenticatorMock!
	var hostProvider: HostProviderMock!
	
	override func setUp() {
		super.setUp()
		
		dispatcher = OperationDispatcher()
		
		authenticator = AuthenticatorMock()
		authenticator.authenticationParameters = [.string(name: "What's the password, member?", value: "Yeah, I member!")]
		
		hostProvider = HostProviderMock()
		hostProvider.defaultHostName = "domain.com"
		
		builder = PCloudAPIDownloadTaskBuilder(hostProvider: hostProvider,
											   authenticator: authenticator,
											   defaultTimeoutInterval: nil,
											   operationBuilder: dispatcher.downloadOperation)
	}
	
	func testFallsBackToDefaultTimeoutIntervalWhenTimeoutIntervalIsNotProvided() {
		// Given
		let defaultTimeoutInterval: TimeInterval = 30
		builder = PCloudAPIDownloadTaskBuilder(hostProvider: hostProvider,
											   authenticator: authenticator,
											   defaultTimeoutInterval: defaultTimeoutInterval,
											   operationBuilder: dispatcher.downloadOperation)
		
		// When
		_ = builder.createTask(with: URL(string: "http://dummy.com")!, timeoutInterval: nil, destination: { $0 })
		
		// Expect
		guard let request = dispatcher.lastDownloadRequest else {
			XCTFail("expected download request to exist")
			return
		}
		
		XCTAssert(request.timeoutInterval == defaultTimeoutInterval, "not falling back to default timeout interval when timeout interval is not specified")
	}
	
	func testRespectsTimeoutInterval() {
		// Given
		let taskTimeoutInterval: TimeInterval = 10
		builder = PCloudAPIDownloadTaskBuilder(hostProvider: hostProvider,
											   authenticator: authenticator,
											   defaultTimeoutInterval: 30,
											   operationBuilder: dispatcher.downloadOperation)
		
		// When
		_ = builder.createTask(with: URL(string: "http://dummy.com")!, timeoutInterval: taskTimeoutInterval, destination: { $0 })
		
		// Expect
		guard let request = dispatcher.lastDownloadRequest else {
			XCTFail("expected download request to exist")
			return
		}
		
		XCTAssert(request.timeoutInterval == taskTimeoutInterval, "not respecting timeout interval")
	}
}


final class OperationDispatcher {
	var lastCallRequest: Call.Request?
	var lastUploadRequest: Upload.Request?
	var lastDownloadRequest: Download.Request?
	
	func callOperation(from request: Call.Request) -> CallOperation {
		lastCallRequest = request
		return CallOperationMock()
	}
	
	func uploadOperation(from request: Upload.Request) -> UploadOperation {
		lastUploadRequest = request
		return UploadOperationMock()
	}
	
	func downloadOperation(from request: Download.Request) -> DownloadOperation {
		lastDownloadRequest = request
		return DownloadOperationMock()
	}
}

final class AuthenticatorMock: Authenticator {
	var authenticationParameters: [Call.Command.Parameter] = []
}

final class HostProviderMock: HostProvider {
	var defaultHostName: String = ""
}
