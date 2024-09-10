//
//  UInt64+Clamping.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 10.09.24.
//  Copyright © 2024 pCloud LTD. All rights reserved.
//

import Foundation

extension UInt64 {
	init(clamping value: Double) {
		self.init(clamping: NSNumber(value: value).int64Value)
	}
	
	init(clamping value: Float) {
		self.init(clamping: NSNumber(value: value).int64Value)
	}
}
