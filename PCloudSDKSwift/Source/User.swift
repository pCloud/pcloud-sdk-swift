//
//  User.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation

/// User namespace.
public struct User {
	/// A pCloud user.
	open class Metadata {
		/// The unique identifier of this user.
		public let id: UInt64
		/// The email address this user has registered with.
		public let emailAddress: String
		/// `true` if the user has verified their email address, `false` otherwise.
		public let isEmailVerified: Bool
		/// The size of this user's content in bytes.
		public let usedQuota: UInt64
		/// The available storage space in bytes.
		public let availableQuota: UInt64
		
		/// Initializes a user with all fields of this class.
		public init(id: UInt64, emailAddress: String, isEmailVerified: Bool, usedQuota: UInt64, availableQuota: UInt64) {
			self.id = id
			self.emailAddress = emailAddress
			self.isEmailVerified = isEmailVerified
			self.usedQuota = usedQuota
			self.availableQuota = availableQuota
		}
	}
}

extension User.Metadata: CustomStringConvertible {
	open var description: String {
		let quotaProgress = (Float(usedQuota) / Float(availableQuota)) * 100
		return "id=\(id), email=\(emailAddress), verified=\(isEmailVerified), quota=\(usedQuota) / \(availableQuota); \(quotaProgress)%"
	}
}

extension User.Metadata: Hashable {
	open func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

public func ==(lhs: User.Metadata, rhs: User.Metadata) -> Bool {
	return lhs.id == rhs.id
}


/// Parses `User.Metadata` from a pCloud API response dictionary.
public struct UserMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String: Any]) throws -> User.Metadata {
		return User.Metadata(id: input.uint64("userid"),
		                     emailAddress: input.string("email"),
		                     isEmailVerified: input.bool("emailverified"),
		                     usedQuota: input.uint64("usedquota"),
		                     availableQuota: input.uint64("quota"))
	}
}
