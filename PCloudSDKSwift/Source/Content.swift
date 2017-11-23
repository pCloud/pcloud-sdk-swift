//
//  Content.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// A folder content item.
public enum Content {
	/// A file.
	case file(File.Metadata)
	/// A folder.
	case folder(Folder.Metadata)
	
	/// Base class for a folder content item in pCloud with common fields for files and folders.
	open class Metadata {
		/// The unique identifier of this content item.
		public let id: UInt64
		/// The name of this content item as it appears in the file system.
		public let name: String
		/// The unique identifier of the parent folder of this item.
		public let parentFolderId: UInt64
		/// The unix timestamp of the creation time of this content item. This is the time the file was created in the pCloud file system.
		public let createdTime: UInt32
		/// The unix timestamp of the last modification time of this content item's metadata or content (for files).
		public let modifiedTime: UInt32
		/// `true` if this content item is accessible to other people through folder sharing, `false` otherwise.
		public let isShared: Bool
		
		/// Initializes a content item with all fields of this class.
		public init(id: UInt64,
		            name: String,
		            parentFolderId: UInt64,
		            createdTime: UInt32,
		            modifiedTime: UInt32,
		            isShared: Bool) {
			self.id = id
			self.name = name
			self.parentFolderId = parentFolderId
			self.createdTime = createdTime
			self.modifiedTime = modifiedTime
			self.isShared = isShared
		}
	}
}

public extension Content {
	/// `true` if this content item is a folder, `false` otherwise.
	var isFolder: Bool {
		if case .folder(_) = self {
			return true
		}
		
		return false
	}
	
	/// `true` if this content item is a file, `false` otherwise.
	var isFile: Bool {
		return !isFolder
	}
	
	/// The folder metadata for this content item. Non-`nil` only when this content item is a folder.
	var folderMetadata: Folder.Metadata? {
		if case .folder(let meta) = self {
			return meta
		}
		
		return nil
	}
	
	// The file metadata for this content item. Non-`nil` only when this content item is a file.
	var fileMetadata: File.Metadata? {
		if case .file(let meta) = self {
			return meta
		}
		
		return nil
	}
}

extension Content: CustomStringConvertible {
	public var description: String {
		switch self {
		case .file(let meta): return "file \(meta)"
		case .folder(let meta): return "folder \(meta)"
		}
	}
}

/// File namespace.
public struct File {
	/// A major file category.
	public enum Media {
		/// Not falling into any other major file categories.
		case uncategorized
		/// An audio file.
		case audio(AudioMetadata)
		/// An image file.
		case image(ImageMetadata)
		/// A video file.
		case video(VideoMetadata)
		/// A document file.
		case document
		/// An archive.
		case archive
		
		/// Audio-file-specific metadata.
		public struct AudioMetadata {
			public var title: String?
			public var artist: String?
			public var album: String?
			public var genre: String?
			public var trackno: Int?
			
			public init() {}
			
			public init(title: String?, artist: String?, album: String?, genre: String?, trackno: Int?) {
				self.title = title
				self.artist = artist
				self.album = album
				self.genre = genre
				self.trackno = trackno
			}
		}
		
		/// Video-file-specific metadata.
		public struct VideoMetadata {
			public var resolution: CGSize?
			public var duration: Float?
			
			public init() {}
			
			public init(resolution: CGSize?, duration: Float?) {
				self.resolution = resolution
				self.duration = duration
			}
		}
		
		/// Image-file-specific metadata.
		public struct ImageMetadata {
			public var resolution: CGSize?
			
			public init() {}
			
			public init(resolution: CGSize?) {
				self.resolution = resolution
			}
		}
		
		/// A file type.
		public enum Icon {
			/// Unknown to the pCloud API.
			case unknown
			/// Image file.
			case image
			/// Video file.
			case video
			/// Audio file.
			case audio
			/// Generic document file.
			case document
			/// An archive.
			case archive
			/// Word document.
			case wordDocument
			/// PowerPoint document.
			case powerPointDocument
			/// Excel document.
			case excelDocument
			/// Pages document.
			case pagesDocument
			/// Keynote document.
			case keynoteDocument
			/// Numbers document.
			case numbersDocument
			/// OpenDocument text document.
			case odtDocument
			/// OpenDocument spreadsheet document.
			case odsDocument
			/// OpenDocument presentation document.
			case odpDocument
			/// Windows executable.
			case windowsExecutable
			/// PDF document.
			case pdfDocument
			/// HTLM document.
			case htmlDocument
			/// eBook.
			case eBookDocument
			/// macOS executable.
			case macOSExecutable
			/// macOS disk image.
			case macOSDiskImage
		}
	}
	
	/// A pCloud file.
	open class Metadata: Content.Metadata {
		/// The file category.
		public let media: Media
		/// The size of the file in bytes.
		public let size: UInt64
		/// The MIME type of this file.
		public let contentType: String
		/// A number uniquely identifying the contents of this file.
		public let hash: UInt64
		/// The file type.
		public let icon: Media.Icon
		/// `true` if the user accessing this file is its owner, `false` otherwise.
		public let isOwnedByUser: Bool
		/// `true` if a thumbnail can be generated for this file, `false` otherwise.
		public let hasThumbnail: Bool
		
		/// Initializes a file with all fields of this class.
		public init(id: UInt64,
		            name: String,
		            parentFolderId: UInt64,
		            createdTime: UInt32,
		            modifiedTime: UInt32,
		            isShared: Bool,
		            icon: Media.Icon,
		            media: Media,
		            size: UInt64,
		            contentType: String,
		            hash: UInt64,
		            isOwnedByUser: Bool,
		            hasThumbnail: Bool) {
			self.media = media
			self.size = size
			self.contentType = contentType
			self.hash = hash
			self.icon = icon
			self.isOwnedByUser = isOwnedByUser
			self.hasThumbnail = hasThumbnail
			
			super.init(id: id,
			           name: name,
			           parentFolderId: parentFolderId,
			           createdTime: createdTime,
			           modifiedTime: modifiedTime,
			           isShared: isShared)
		}
	}
}

extension File.Metadata {
	/// `true` if this file's media is `Media.uncategorized`, `false` otherwise.
	open var isUncategorized: Bool {
		if case .uncategorized = media {
			return true
		}
		
		return false
	}
	
	/// `true` if this file's media is `Media.audio`, `false` otherwise.
	open var isAudio: Bool {
		if case .audio(_) = media {
			return true
		}
		
		return false
	}
	
	/// `true` if this file's media is `Media.image`, `false` otherwise.
	open var isImage: Bool {
		if case .image(_) = media {
			return true
		}
		
		return false
	}
	
	/// `true` if this file's media is `Media.video`, `false` otherwise.
	open var isVideo: Bool {
		if case .video(_) = media {
			return true
		}
		
		return false
	}
	
	/// `true` if this file's media is `Media.document`, `false` otherwise.
	open var isDocument: Bool {
		if case .document = media {
			return true
		}
		
		return false
	}
	
	/// `true` if this file's media is `Media.archive`, `false` otherwise.
	open var isArchive: Bool {
		if case .archive = media {
			return true
		}
		
		return false
	}
	
	/// The audio metadata of this file. Non-`nil` only when this file's media is `Media.audio`.
	open var audioMetadata: File.Media.AudioMetadata? {
		if case .audio(let meta) = media {
			return meta
		}
		
		return nil
	}
	
	/// The image metadata of this file. Non-`nil` only when this file's media is `image`.
	open var imageMetadata: File.Media.ImageMetadata? {
		if case .image(let meta) = media {
			return meta
		}
		
		return nil
	}
	
	/// The video metadata of this file. Non-`nil` only when this file's media is `vidoe`.
	open var videoMetadata: File.Media.VideoMetadata? {
		if case .video(let meta) = media {
			return meta
		}
		
		return nil
	}
}

extension File.Media.ImageMetadata: CustomStringConvertible {
	public var description: String {
		if let resolution = resolution {
			return "\(resolution.width)x\(resolution.height)"
		}
		
		return "nil"
	}
}

extension File.Media.VideoMetadata: CustomStringConvertible {
	public var description: String {
		if let duration = duration {
			return "\(duration) s"
		}
		
		return "nil"
	}
}

extension File.Media.AudioMetadata: CustomStringConvertible {
	public var description: String {
		return "\(artist as Any) - \(title as Any)"
	}
}

extension File.Media.Icon: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unknown: return "unknown"
		case .image: return "image"
		case .video: return "video"
		case .audio: return "audio"
		case .document: return "document"
		case .archive: return "archive"
		case .wordDocument: return "word document"
		case .powerPointDocument: return "power point document"
		case .excelDocument: return "excel document"
		case .pagesDocument: return "pages document"
		case .keynoteDocument: return "keynote document"
		case .numbersDocument: return "numbers document"
		case .odtDocument: return "odt document"
		case .odsDocument: return "ods document"
		case .odpDocument: return "odp document"
		case .windowsExecutable: return "windows executable"
		case .pdfDocument: return "pdf document"
		case .htmlDocument: return "html document"
		case .eBookDocument: return "ebook"
		case .macOSExecutable: return "macos executable"
		case .macOSDiskImage: return "macos disk image"
		}
	}
}

extension File.Media: CustomStringConvertible {
	public var description: String {
		switch self {
		case .uncategorized: return "uncategorized"
		case .image(let meta): return "image \(meta)"
		case .video(let meta): return "video \(meta)"
		case .audio(let meta): return "audio \(meta)"
		case .document: return "document"
		case .archive: return "archive"
		}
	}
}

extension File.Media: Equatable {
}

public func ==(lhs: File.Media, rhs: File.Media) -> Bool {
	switch (lhs, rhs) {
	case (.uncategorized, .uncategorized): return true
	case (.image(_), .image(_)): return true
	case (.video(_), .video(_)): return true
	case (.audio(_), .audio(_)): return true
	case (.document, .document): return true
	case (.archive, .archive): return true
	default: return false
	}
}

extension File.Metadata: CustomStringConvertible {
	open var description: String {
		return "id=\(id), name=\(name), parent=\(parentFolderId), hash=\(hash), size=\(size), \(media)"
	}
}

public func ==(lhs: File.Metadata, rhs: File.Metadata) -> Bool {
	return lhs.id == rhs.id
}

extension File.Metadata: Hashable {
	open var hashValue: Int {
		return id.hashValue
	}
}


/// Folder namespace.
public struct Folder {
	/// The identifier of the root folder in every user account.
	public static let root: UInt64 = 0
	
	/// Folder permissions.
	/// Folder permissions apply to folders not owned by the users that access them. They are controlled by the owner of the folder.
	public struct Permissions {
		/// Users can access this folder's metadata and the metadata of its children recursively.
		public var canRead = true
		/// Users can create folders, upload files and copy files and folders to this folder.
		public var canCreate = false
		/// Users can modify the content of files inside this folder. Files and folders can also be renamed.
		public var canModify = false
		/// Users can delete and move content inside this folder.
		public var canDelete = false
		
		public init() {}
		
		public init(canRead: Bool, canCreate: Bool, canModify: Bool, canDelete: Bool) {
			self.canRead = canRead
			self.canCreate = canCreate
			self.canModify = canModify
			self.canDelete = canDelete
		}
	}
	
	public enum Ownership {
		/// The user that accesses this folder is its owner.
		case ownedByUser
		/// The user that accesses this folder is not its owner. This folder is shared with the user and certain permissions apply.
		case notOwnedByUser(Permissions)
	}
	
	/// A pCloud folder.
	open class Metadata: Content.Metadata {
		/// The ownerwhip of this folder.
		public let ownership: Ownership
		/// This folder's immediate children.
		public let contents: [Content]
		
		/// Initializes a folder with all fields of this class.
		public init(id: UInt64,
		            name: String,
		            parentFolderId: UInt64,
		            createdTime: UInt32,
		            modifiedTime: UInt32,
		            isShared: Bool,
		            ownership: Ownership,
		            contents: [Content]) {
			self.ownership = ownership
			self.contents = contents
			
			super.init(id: id,
			           name: name,
			           parentFolderId: parentFolderId,
			           createdTime: createdTime,
			           modifiedTime: modifiedTime,
			           isShared: isShared)
		}
	}
}

extension Folder.Metadata {
	/// `true` if the user accessing this folder is its owner, `false` otherwise.
	open var isOwnedByUser: Bool {
		if case .ownedByUser = ownership {
			return true
		}
		
		return false
	}
	
	/// The folder permissions assigned to this folder by its owner. Non-`nil` only when the user accessing this folder is not its owner.
	open var permissions: Folder.Permissions? {
		if case .notOwnedByUser(let permissions) = ownership {
			return permissions
		}
		
		return nil
	}
}

extension Folder.Permissions: CustomStringConvertible {
	public var description: String {
		var result = ""
		
		result += canRead ? "R" : "-"
		result += canCreate ? "C" : "-"
		result += canModify ? "M" : "-"
		result += canDelete ? "D" : "-"

		return result
	}
}

extension Folder.Ownership: CustomStringConvertible {
	public var description: String {
		switch self {
		case .ownedByUser: return "owned by user"
		case .notOwnedByUser(let permissions): return "not owned by user; \(permissions)"
		}
	}
}

extension Folder.Metadata: CustomStringConvertible {
	open var description: String {
		return "id=\(id), name=\(name), parent=\(parentFolderId), \(ownership), contains \(contents.count) items"
	}
}

/// Parses `File.Media.Icon` from a pCloud API response dictionary.
public struct FileIconParser: Parser {
	public init() {}
	
	public func parse(_ input: [String: Any]) throws -> File.Media.Icon {
		let view = ApiResponseView(input)
		
		switch view.int("icon") {
		case 0: return .unknown
		case 1: return .image
		case 2: return .video
		case 3: return .audio
		case 4: return .document
		case 5: return .archive
		case 6: return .wordDocument
		case 7: return .powerPointDocument
		case 8: return .excelDocument
		case 10: return .pagesDocument
		case 11: return .keynoteDocument
		case 12: return .numbersDocument
		case 13: return .odtDocument
		case 14: return .odsDocument
		case 15: return .odpDocument
		case 16: return .windowsExecutable
		case 17: return .pdfDocument
		case 18: return .htmlDocument
		case 21: return .eBookDocument
		case 22: return .macOSExecutable
		case 23: return .macOSDiskImage
		default: return .unknown
		}
	}
}

/// Parses `File.Media.ImageMetadata` from a pCloud API response dictionary.
public struct ImageMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String : Any]) throws -> File.Media.ImageMetadata {
		let view = ApiResponseView(input)
		
		let resolution: CGSize? = {
			if let width = view.intOrNil("width"), let height = view.intOrNil("height") {
				return CGSize(width: width, height: height)
			}
			
			return nil
		}()
		
		return File.Media.ImageMetadata(resolution: resolution)
	}
}

/// Parses `File.Media.VideoMetadata` from a pCloud API response dictionary.
public struct VideoMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String : Any]) throws -> File.Media.VideoMetadata {
		let view = ApiResponseView(input)
		
		let resolution: CGSize? = {
			if let width = view.intOrNil("width"), let height = view.intOrNil("height") {
				return CGSize(width: width, height: height)
			}
			
			return nil
		}()
		
		let duration: Float? = {
			guard let stringValue = view.stringOrNil("duration") else {
				return nil
			}
			
			return Float(stringValue)
		}()
		
		return File.Media.VideoMetadata(resolution: resolution, duration: duration)
	}
}

/// Parses `File.Media.AudioMetadata` from a pCloud API response dictionary.
public struct AudioMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String : Any]) throws -> File.Media.AudioMetadata {
		let view = ApiResponseView(input)
		return File.Media.AudioMetadata(title: view.stringOrNil("title"),
		                                artist: view.stringOrNil("artist"),
		                                album: view.stringOrNil("album"),
		                                genre: view.stringOrNil("genre"),
		                                trackno: view.intOrNil("trackno"))
	}
}

/// Parses `File.Metadata` from a pCloud API response dictionary.
public struct FileMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String : Any]) throws -> File.Metadata {
		let view = ApiResponseView(input)
		
		let media: File.Media = try {
			switch view.int("category") {
			case 0: return .uncategorized
			case 1: return .image(try ImageMetadataParser().parse(input))
			case 2: return .video(try VideoMetadataParser().parse(input))
			case 3: return .audio(try AudioMetadataParser().parse(input))
			case 4: return .document
			case 5: return .archive
			default: return .uncategorized
			}
		}()
		
		return File.Metadata(id: view.uint64("fileid"),
		                     name: view.string("name"),
		                     parentFolderId: view.uint64("parentfolderid"),
		                     createdTime: view.uint32("created"),
		                     modifiedTime: view.uint32("modified"),
		                     isShared: view.boolOrNil("isshared") ?? false,
		                     icon: try FileIconParser().parse(input),
		                     media: media,
		                     size: view.uint64("size"),
		                     contentType: view.string("contenttype"),
		                     hash: view.uint64("hash"),
		                     isOwnedByUser: view.bool("ismine"),
		                     hasThumbnail: view.boolOrNil("thumb") ?? false)
	}
}

/// Parses `Array<Content>` from a pCloud API response dictionary.
public struct ContentListParser: Parser {
	public init() {}
	
	public func parse(_ input: [[String : Any]]) throws -> [Content] {
		let fileParser = FileMetadataParser()
		let folderParser = FolderMetadataParser()
		
		return try input.map { entry in
			let view = ApiResponseView(entry)
			
			if view.bool("isfolder") {
				return .folder(try folderParser.parse(entry))
			}
			
			return .file(try fileParser.parse(entry))
		}
	}
}

/// Parses `Folder.Metadata` from a pCloud API response dictionary.
public struct FolderMetadataParser: Parser {
	public init() {}
	
	public func parse(_ input: [String : Any]) throws -> Folder.Metadata {
		let view = ApiResponseView(input)
		
		let ownership: Folder.Ownership = {
			if view.bool("ismine") {
				return .ownedByUser
			}
			
			return .notOwnedByUser(Folder.Permissions(canRead: view.bool("canread"),
			                                          canCreate: view.bool("cancreate"),
			                                          canModify: view.bool("canmodify"),
			                                          canDelete: view.bool("candelete")))
		}()
		
		let contents: [Content] = try {
			if let contents = input["contents"] as! [[String: Any]]? {
				return try ContentListParser().parse(contents)
			}
			
			return []
		}()
		
		return Folder.Metadata(id: view.uint64("folderid"),
		                       name: view.string("name"),
		                       parentFolderId: view.uint64OrNil("parentfolderid") ?? 0,
		                       createdTime: view.uint32("created"),
		                       modifiedTime: view.uint32("modified"),
		                       isShared: view.boolOrNil("isshared") ?? false,
		                       ownership: ownership,
		                       contents: contents)
	}
}
