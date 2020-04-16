//
//  FileLink.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// FileLink namespace.
public struct FileLink {
	/// An address to a remote resource in pCloud. Available for a specific time interval.
	open class Metadata {
		/// The address of the resource.
		public let address: URL
		/// When `address` becomes unreachable.
		public let expirationDate: Date
		/// A token authenticating the client requesting the file link to the storage server.
		public let downloadTag: String
		
		/// Initializes a file link with an address and expiration date.
		public init(address: URL, expirationDate: Date, downloadTag: String) {
			self.address = address
			self.expirationDate = expirationDate
			self.downloadTag = downloadTag
		}
	}
}

extension FileLink.Metadata: CustomStringConvertible {
	open var description: String {
		return address.description
	}
}

extension FileLink.Metadata: Hashable {
	open func hash(into hasher: inout Hasher) {
		hasher.combine(address)
		hasher.combine(expirationDate)
	}
}

public func ==(lhs: FileLink.Metadata, rhs: FileLink.Metadata) -> Bool {
	return lhs.address == rhs.address && lhs.expirationDate == rhs.expirationDate
}


/// Parses `Array<FileLink.Metadata>` from a pCloud API response dictionary.
public struct FileLinkMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String: Any]) throws -> [FileLink.Metadata] {
		let hosts = input["hosts"] as! [String]
		let path = input.string("path")
		let expirationTimestamp = input.uint32("expires")
		let downloadTag = input.string("dwltag")
		
		return hosts.map { host in
			var components = URLComponents()
			components.scheme = Scheme.https.rawValue
			components.host = host
			components.path = path
			
			return FileLink.Metadata(address: components.url!, expirationDate: Date(timeIntervalSince1970: TimeInterval(expirationTimestamp)), downloadTag: downloadTag)
		}
	}
}
