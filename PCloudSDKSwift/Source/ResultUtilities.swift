//
//  Result.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

extension Result {
	var isSuccess: Bool {
		if case .success(_) = self {
			return true
		}
		
		return false
	}
	
	var isFailure: Bool {
		return !isSuccess
	}
}
