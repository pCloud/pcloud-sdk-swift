//
//  UploadInfo.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

public struct UploadInfo {
	public let dataSize: UInt64
	public let dataSHA1: String
	public let dataMD5: String
}

public struct UploadInfoParser: Parser {
	public func parse(_ input: [String: Any]) throws -> UploadInfo {
		return UploadInfo(dataSize: input.uint64("size"), dataSHA1: input.string("sha1"), dataMD5: input.string("md5"))
	}
}
