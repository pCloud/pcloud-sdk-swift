//
//  OAuthTests.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import XCTest
@testable import PCloudSDKSwift

final class OAuthTests: XCTestCase {
	func createRedirectUrl(appKey: String, fragment: String?) -> URL {
		var components = URLComponents()
		components.scheme = "pclsdk-w-\(appKey)"
		components.host = "oauth2redirect"
		components.fragment = fragment
		
		return components.url!
	}
	
	func testCreatesCorrectRedirectionUrl() {
		// Given
		let appKey = "foo"
		
		// When
		let url = OAuth.createRedirectUrl(appKey: appKey)
		
		// Expect
		let expectedUrl = createRedirectUrl(appKey: appKey, fragment: nil).absoluteString
		XCTAssert(url == expectedUrl, "invalid redirect url, expected \(expectedUrl), got \(url)")
	}
	
	func testCreatesCorrectAuthorizationUrl() {
		// Given
		let appKey = "foo"
		let redirectUrl = createRedirectUrl(appKey: appKey, fragment: nil).absoluteString
		
		// When
		let url = URLComponents(string: OAuth.createAuthorizationUrl(appKey: appKey, redirectUrl: redirectUrl).absoluteString)!
		
		// Expect
		XCTAssert(url.scheme == "https", "invalid scheme")
		XCTAssert(url.host == "e.pcloud.com", "invalid host")
		XCTAssert(url.path == "/oauth2/authorize", "invalid path")
		
		let query = (url.queryItems ?? []).dictionary(transform: { ($0.name, $0.value!) })
		
		XCTAssert(query["client_id"] == appKey, "invalid client id")
		XCTAssert(query["response_type"] == "token", "invalid response type")
		XCTAssert(query["redirect_uri"] == redirectUrl, "invalid redirect url")
	}
	
	func testHandleRedirectUrlReturnsNilWhenProvidedUrlIsNotARedirectUrl() {
		// Given
		let url = URL(string: "https://dummy.com")!
		
		// When
		let result = OAuth.handleRedirectUrl(url, appKey: "foo")
		
		// Expect
		XCTAssert(result == nil, "unexpected redirect result")
	}
	
	func testHandleRedirectUrlReturnsAccessDeniedErrorWhenUrlDoesNotContainFragment() {
		// Given
		let url = createRedirectUrl(appKey: "foo", fragment: nil)
		
		// When
		let result = OAuth.handleRedirectUrl(url, appKey: "foo")!
		
		// Expect
		validate(result, against: .failure(OAuth.Error.accessDenied))
	}
	
	func testHandleRedirectUrlReturnsTokenOnAccessTokenResponse() {
		// Given
		let url = createRedirectUrl(appKey: "foo", fragment: "access_token=thetoken&userid=42")
		
		// When
		let result = OAuth.handleRedirectUrl(url, appKey: "foo")!
		
		// Expect
		validate(result, against: .success(token: "thetoken", userId: 42))
	}
	
	func testHandleRedirectUrlReturnsErrorOnErrorResponse() {
		for (code, error) in oauth2ErrorCodes() {
			// Given
			let url = createRedirectUrl(appKey: "foo", fragment: "error=\(code)")
			
			// When
			let result = OAuth.handleRedirectUrl(url, appKey: "foo")!
			
			// Expect
			validate(result, against: .failure(error))
		}
	}
	
	func testHandleRedirectUrlReturnsUnknownErrorOnUnknownErrorResponse() {
		// Given
		let url = createRedirectUrl(appKey: "foo", fragment: "error=krokodil")
		
		// When
		let result = OAuth.handleRedirectUrl(url, appKey: "foo")!
		
		// Expect
		validate(result, against: .failure(OAuth.Error.unknown))
	}
	
	func testAuthorizationFlowPresentsWebView() {
		// Given
		let view = AuthorizationFlowViewMock()
		
		// When
		OAuth.performAuthorizationFlow(view: view, appKey: "", storeToken: { _,_  in }) { _ in }
		
		// Expect
		XCTAssert(view.presentInvoked, "should present web view")
	}
	
	func testAuthorizationFlowDoesNothingWhenInterceptingNonOAuthRedirect() {
		// Given
		let view = AuthorizationFlowViewMock()
		let url = URL(string: "https://google.com")!
		
		// When
		OAuth.performAuthorizationFlow(view: view, appKey: "", storeToken: { _,_  in }) { _ in
			// Expect
			XCTFail("should not invoke completion block")
		}
		
		let result = view.invokeInterceptBlock(url: url)
		
		// Expect
		XCTAssert(!result, "should not handle url")
		XCTAssert(!view.dismissInvoked, "should not dismiss view")
	}
	
	func testAuthorizationFlowInvokesCompletionBlockWhenCancelled() {
		// Given
		let view = AuthorizationFlowViewMock()
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// When
		OAuth.performAuthorizationFlow(view: view, appKey: "", storeToken: { _,_  in }) { result in
			// Expect
			invokeExpectation.fulfill()
			
			switch result {
			case .cancel: break
			default: XCTFail("invalid result; expected cancel, got \(result)")
			}
		}
		
		view.invokeCancelBlock()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testAuthorizationFlowInvokesCompletionBlockWhenInterceptingOAuthRedirect() {
		// Given
		let url = createRedirectUrl(appKey: "foo", fragment: "access_token=thetoken&userid=42")
		let view = AuthorizationFlowViewMock()
		let invokeExpectation = expectation(description: "to invoke completion block")
		
		// When
		OAuth.performAuthorizationFlow(view: view, appKey: "foo", storeToken: { _,_  in }) { _ in
			// Expect
			invokeExpectation.fulfill()
		}
		
		let result = view.invokeInterceptBlock(url: url)
		
		// Expect
		XCTAssert(result, "should handle url")
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testAuthorizationFlowStoresTokenOnAccessTokenResponse() {
		// Given
		let url = createRedirectUrl(appKey: "foo", fragment: "access_token=thetoken&userid=42")
		let view = AuthorizationFlowViewMock()
		let invokeExpectation = expectation(description: "to invoke store token block")
		
		let storeBlock: (String, UInt64) -> Void = { token, user in
			// Expect
			invokeExpectation.fulfill()
		}
		
		// When
		OAuth.performAuthorizationFlow(view: view, appKey: "foo", storeToken: storeBlock, { _ in })
		_ = view.invokeInterceptBlock(url: url)
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func oauth2ErrorCodes() -> [String: OAuth.Error] {
		return [
			"invalid_request": .invalidRequest,
			"unauthorized_client": .unauthorizedClient,
			"access_denied": .accessDenied,
			"unsupported_response_type": .unsupportedResponseType,
			"invalid_scope": .invalidScope,
			"server_error": .serverError,
			"temporarily_unavailable": .temporarilyUnavailable
		]
	}
	
	func validate(_ result: OAuth.Result, against expected: OAuth.Result) {
		switch (result, expected) {
		case let (.success(lhsPayload), .success(rhsPayload)) where lhsPayload == rhsPayload: break
		case let (.failure(lhsError), .failure(rhsError)) where lhsError == rhsError: break
		default: XCTFail("invalid authorization result; expected \(expected), got \(result)")
		}
	}
}

final class AuthorizationFlowViewMock: OAuthAuthorizationFlowView {
	private(set) var presentInvoked = false
	private(set) var dismissInvoked = false
	
	private var interceptBlock: ((URL) -> Bool)?
	private var cancelBlock: (() -> Void)?
	
	func invokeInterceptBlock(url: URL) -> Bool {
		return interceptBlock!(url)
	}
	
	func invokeCancelBlock() {
		cancelBlock!()
	}
	
	func presentWebView(url: URL, interceptNavigation: @escaping (URL) -> Bool, didCancel: @escaping () -> Void) {
		presentInvoked = true
		interceptBlock = interceptNavigation
		cancelBlock = didCancel
	}
	
	func dismissWebView() {
		dismissInvoked = true
	}
}

extension Collection {
	func dictionary<K, V>(transform: (_ element: Iterator.Element) -> (K, V)) -> [K: V] {
		var result: [K: V] = [:]
		
		for element in self {
			let tuple = transform(element)
			result[tuple.0] = tuple.1
		}
		
		return result
	}
}
