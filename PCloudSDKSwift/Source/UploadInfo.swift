//
//  UploadInfo.swift
//  SDK iOS
//
//  Created by Todor Pitekov on 11/28/17.
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// The state of a pCloud API upload session.
public struct UploadInfo {
	/// The number of bytes written to this upload.
	public let dataSize: UInt64
	/// The SHA1 digest in hex representation of the uploaded data.
	public let dataSHA1: String
	/// The MD5 digest in hex representation of the uploaded data.
	public let dataMD5: String
	
	public init(dataSize: UInt64, dataSHA1: String, dataMD5: String) {
		self.dataSize = dataSize
		self.dataSHA1 = dataSHA1
		self.dataMD5 = dataMD5
	}
}

/// Parses `UploadInfo` from a pCloud API response dictionary.
public struct UploadInfoParser: Parser {
	public init() {}
	
	public func parse(_ input: [String: Any]) throws -> UploadInfo {
		return UploadInfo(dataSize: input.uint64("size"), dataSHA1: input.string("sha1"), dataMD5: input.string("md5"))
	}
}
