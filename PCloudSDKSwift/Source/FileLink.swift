//
//  FileLink.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// FileLink namespace.
public struct FileLink {
	/// An address to a remote resource in pCloud. Available for a specific time interval.
	public class Metadata {
		/// The address of the resource.
		public let address: URL
		/// When `address` becomes unreachable.
		public let expirationDate: Date
		
		/// Initializes a file link with an address and expiration date.
		init(address: URL, expirationDate: Date) {
			self.address = address
			self.expirationDate = expirationDate
		}
	}
}

extension FileLink.Metadata: CustomStringConvertible {
	public var description: String {
		return address.description
	}
}

extension FileLink.Metadata: Hashable {
	public var hashValue: Int {
		return address.hashValue ^ expirationDate.hashValue
	}
}

public func ==(lhs: FileLink.Metadata, rhs: FileLink.Metadata) -> Bool {
	return lhs.address == rhs.address && lhs.expirationDate == rhs.expirationDate
}


/// Parses `Array<FileLink.Metadata>` from a pCloud API response dictionary.
public struct FileLinkMetadataParser: Parser {
	public func parse(_ input: [String: Any]) throws -> [FileLink.Metadata] {
		let view = ApiResponseView(input)
		let hosts = input["hosts"] as! [String]
		let path = view.string("path")
		let expirationTimestamp = view.uint32("expires")
		
		return hosts.map { host in
			var components = URLComponents()
			components.scheme = Scheme.https.rawValue
			components.host = host
			components.path = path
			
			return FileLink.Metadata(address: components.url!, expirationDate: Date(timeIntervalSince1970: TimeInterval(expirationTimestamp)))
		}
	}
}
