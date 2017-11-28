//
//  Utilities.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import XCTest
@testable import PCloudSDKSwift

extension Result {
	func shallowEquals(_ other: Result) -> Bool {
		switch (self, other) {
		case (.success(_), .success(_)): return true
		case (.failure(_), .failure(_)): return true
		default: return false
		}
	}
}

extension NSError {
	static func void() -> Error {
		return NSError(domain: "holy mother of jesus", code: 1, userInfo: nil)
	}
}
