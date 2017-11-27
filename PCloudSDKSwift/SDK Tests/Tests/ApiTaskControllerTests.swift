//
//  APITaskControllerTests.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation
import XCTest
@testable import PCloudSDKSwift


final class APITaskControllerTests: XCTestCase {
	var controller: APITaskController!
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
		
		controller = APITaskController(hostProvider: hostProvider,
		                               authenticator: authenticator,
		                               callDispatcher: dispatcher.callOperation,
		                               uploadDispatcher: dispatcher.uploadOperation,
		                               downloadDispatcher: dispatcher.downloadOperation)
	}
	
	override func tearDown() {
		dispatcher = nil
		authenticator = nil
		hostProvider = nil
		controller = nil
		
		super.tearDown()
	}
}

extension APITaskControllerTests {
	func testAuthenticatesCallCommandsRequiringAuthentication() {
		// Given
		var command = VoidAPIMethod()
		command.requiresAuthentication = true
		
		// When
		_ = controller.call(command)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).isSuperset(of: Set(authenticator.authenticationParameters)), "call command should be authenticated")
	}
	
	func testDoesNotAuthenticateCallCommandsNotRequiringAuthentication() {
		// Given
		var command = VoidAPIMethod()
		command.requiresAuthentication = false
		
		// When
		_ = controller.call(command)
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).intersection(Set(authenticator.authenticationParameters)).isEmpty, "call command should not be authenticated")
	}
	
	func testAuthenticatesUploadCommandRequiringAuthentication() {
		// Given
		var command = VoidAPIMethod()
		command.requiresAuthentication = true
		
		// When
		_ = controller.upload(command, body: .data(Data()))
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).isSuperset(of: Set(authenticator.authenticationParameters)), "upload command should be authenticated")
	}
	
	func testDoesNotAuthenticateUploadCommandsNotRequiringAuthentication() {
		// Given
		let authParameter: Call.Command.Parameter = .string(name: "What's the password, member?", value: "Yeah, I member!")
		authenticator.authenticationParameters = [authParameter]
		
		var command = VoidAPIMethod()
		command.requiresAuthentication = false
		
		// When
		_ = controller.upload(command, body: .data(Data()))
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(Set(request.command.parameters).intersection(Set(authenticator.authenticationParameters)).isEmpty, "upload command should not be authenticated")
	}
	
	func testAddsDefaultHostNameToCallRequest() {
		// Given
		hostProvider.defaultHostName = "domain.com"
		
		// When
		_ = controller.call(PCloudAPI.UserInfo())
		
		// Expect
		guard let request = dispatcher.lastCallRequest else {
			XCTFail("expected call request to exist")
			return
		}
		
		XCTAssert(request.hostName == hostProvider.defaultHostName, "incorrect host name attached to call request; expected \(hostProvider.defaultHostName), got \(request.hostName)")
	}
	
	func testAddsDefaultHostNameToUploadRequest() {
		// Given
		hostProvider.defaultHostName = "domain.com"
		
		// When
		_ = controller.upload(PCloudAPI.UploadFile(name: "krokodil", parentFolderId: 0, modificationDate: nil), body: .data(Data()))
		
		// Expect
		guard let request = dispatcher.lastUploadRequest else {
			XCTFail("expected upload request to exist")
			return
		}
		
		XCTAssert(request.hostName == hostProvider.defaultHostName, "incorrect host name attached to upload request; expected \(hostProvider.defaultHostName), got \(request.hostName)")
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

