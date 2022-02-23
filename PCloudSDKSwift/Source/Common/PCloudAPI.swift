//
//  PCloudAPI.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

/// PCloudAPI namespace.
public struct PCloudAPI {
	// Default parameters for all commands.
	
	// Makes all date-related fields in the response unix timestamps.
	private static let defaultTimeFormatParameter = Call.Command.Parameter.string(name: "timeformat", value: "timestamp")
	// Makes all "icon" fields in the response integers.
	private static let defaultIconFormatParameter = Call.Command.Parameter.string(name: "iconformat", value: "id")
	
	/// Authentication-related API errors.
	public enum AuthError: Int {
		/// Authorization is required for this call.
		case logInRequired = 1000
		/// Authorization failed due to invalid login credentials. This may be because of an expired or invalidated token.
		case logInFailed = 2000
	}
	
	/// Permission/access-related API errors.
	public enum PermissionError: Int {
		/// The user is not allowed to perform the requested operation. This may be due to insufficient folder permissions.
		case accessDenied = 2003
		/// The user has exceeded their available storage quota and this action is not allowed.
		case userIsOverQuota = 2008
	}
	
	/// An API error.
	public enum Error<MethodError: RawRepresentable>: RawRepresentable, Swift.Error where MethodError.RawValue == Int {
		/// Authentication-related error.
		case authError(AuthError)
		/// Permission/access-related error.
		case permissionError(PermissionError)
		/// Missing or incorrectly formatted parameters.
		case badInputError(Int, String?)
		/// Error related to the method.
		case methodError(MethodError)
		/// The API is rate limiting this client.
		case rateLimitError
		/// The API cannot currently handle the request. Try again later.
		case serverInternalError(Int, String?)
		/// Unspecified API error.
		case other(Int, String?)
		
		public var rawValue: Int {
			switch self {
			case .authError(let error): return error.rawValue
			case .permissionError(let error): return error.rawValue
			case .badInputError(let code, _): return code
			case .methodError(let error): return error.rawValue
			case .rateLimitError: return 4000
			case .serverInternalError(let code, _): return code
			case .other(let code, _): return code
			}
		}
		
		/// Initializes an API error with an API result code and error message.
		/// Initialization fails if `code` is 0.
		public init?(code: Int, message: String? = nil) {
			guard code != 0 else {
				return nil
			}
			
			if let authError = AuthError(rawValue: code) {
				self = .authError(authError)
			} else if let permissionError = PermissionError(rawValue: code) {
				self = .permissionError(permissionError)
			} else if let methodError = MethodError(rawValue: code) {
				self = .methodError(methodError)
			} else if 1000...1999 ~= code {
				self = .badInputError(code, message)
			} else if code == 4000 {
				self = .rateLimitError
			} else if 5000...5999 ~= code {
				self = .serverInternalError(code, message)
			} else {
				self = .other(code, message)
			}
		}
		
		public init?(rawValue: Int) {
			self.init(code: rawValue)
		}
	}
}


// MARK:- User/account-related methods.

extension PCloudAPI {
	/// Returns metadata about the user.
	public struct UserInfo: PCloudAPIMethod {
		public init() {}
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		public func createResponseParser() -> ([String: Any]) throws -> Result<User.Metadata, PCloudAPI.Error<NullError>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				return .success(try UserMetadataParser().parse($0))
			}
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "userinfo", parameters: [])
		}
	}
}


// MARK:- Methods related to folder operations.

extension PCloudAPI {
	/// Returns metadata for a folder and its contents.
	public struct ListFolder: PCloudAPIMethod {
		/// The identifier of the folder to list.
		public let folderId: UInt64
		
		/// `true` if metadata will be returned for the whole folder tree under the requested folder, `false` if metadata will be
		/// returned only for the immediate children of the requested folder.
		public let recursive: Bool
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter folderId: The folder to fetch metadata for.
		/// - parameter recursive: `true` to fetch the whole folder tree or `false` to fetch only immediate children of the folder.
		public init(folderId: UInt64, recursive: Bool) {
			self.folderId = folderId
			self.recursive = recursive
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "listfolder", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "folderid", value: folderId),
				.boolean(name: "recursive", value: recursive)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Folder.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FolderMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to listing a folder.
		public enum Error: Int {
			/// The requested folder does not exist.
			case folderDoesNotExist = 2005
		}
	}
	
	
	/// Creates a folder and returns its metadata.
	public struct CreateFolder: PCloudAPIMethod {
		/// The name of the new folder.
		public let name: String
		/// The unique identifier of the parent folder.
		public let parentFolderId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter name: A name for the folder.
		/// - parameter parentFolderId: The unique identifier of the parent folder.
		public init(name: String, parentFolderId: UInt64) {
			self.name = name
			self.parentFolderId = parentFolderId
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Folder.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FolderMetadataParser().parse(meta))
			}
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "createfolder", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.string(name: "name", value: name),
				.number(name: "folderid", value: parentFolderId)
			])
		}
		
		/// Errors specific to creating a folder.
		public enum Error: Int {
			/// The requested name is invalid.
			case invalidName = 2001
			/// The parent folder does not exist.
			case componentOfParentDirectoryDoesNotExist = 2002
			/// A folder with the requested name already exists.
			case folderAlreadyExists = 2004
		}
	}
	
	
	/// Renames a folder and returns its updated metadata.
	public struct RenameFolder: PCloudAPIMethod {
		/// The unique identifier of the folder to rename.
		public let folderId: UInt64
		/// The new name of the folder.
		public let newName: String
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter folderId: The unique identifier of the folder to rename.
		/// - parameter newName: A new name for the folder.
		public init(folderId: UInt64, newName: String) {
			self.folderId = folderId
			self.newName = newName
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Folder.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0["metadata"] as! [String: Any]
				return .success(try FolderMetadataParser().parse(meta))
			}
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "renamefolder", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "folderid", value: folderId),
				.string(name: "toname", value: newName)
			])
		}
		
		/// Errors specific to renaming a folder.
		public enum Error: Int {
			/// The requested name is invalid.
			case invalidName = 2001
			/// A folder with the requested name already exists.
			case folderAlreadyExists = 2004
			/// The folder does not exist.
			case folderDoesNotExist = 2005
			/// One does not simply rename the root folder.
			case cannotRenameRootFolder = 2042
		}
	}
	
	
	/// Moves a folder and returns its updated metadata.
	public struct MoveFolder: PCloudAPIMethod {
		/// The unique identifier of the folder to move.
		public let folderId: UInt64
		/// The unique identifier of the destination folder.
		public let destinationFolderId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter folderId: The unique identifier of the folder to move.
		/// - parameter destinationFolderId: The unique identifier of the destination folder.
		public init(folderId: UInt64, destinationFolderId: UInt64) {
			self.folderId = folderId
			self.destinationFolderId = destinationFolderId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "renamefolder", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "folderid", value: folderId),
				.number(name: "tofolderid", value: destinationFolderId)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Folder.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FolderMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to moving a folder.
		public enum Error: Int {
			/// A folder with the same name already exists.
			case folderAlreadyExists = 2004
			/// The folder does not exist.
			case folderDoesNotExist = 2005
			/// Cannot move a shared folder into another shared folder.
			case cannotMoveSharedFolderIntoAnotherSharedFolder = 2023
			/// Cannot move a folder into a subfolder of itself.
			case cannotMoveFolderToSubfolderOfItself = 2043
		}
	}
	
	
	/// Copies a folder and returns the new folder. During copying, folders with the same name will be automatically merged.
	public struct CopyFolder: PCloudAPIMethod {
		/// How file name conflicts should be handled during copying.
		public enum NameConflictPolicy {
			/// Overwrite files in the destination with those from the source.
			case overwrite
			/// Don't copy any files from the source if they already exist at the destination.
			case skip
			/// Fail when a name conflict occurs.
			case fail
		}
		
		/// The unique identifier of the folder to copy.
		public let folderId: UInt64
		/// The unique identifier of the destination folder.
		public let destinationFolderId: UInt64
		/// How file name conflicts should be handled.
		public let nameConflictPolicy: NameConflictPolicy
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter folderId: The unique identifier of the folder to move.
		/// - parameter destinationFolderId: The unique identifier of the destination folder.
		/// - parameter nameConflictPolicy: How file name conflicts should be handled.
		public init(folderId: UInt64, destinationFolderId: UInt64, nameConflictPolicy: NameConflictPolicy) {
			self.folderId = folderId
			self.destinationFolderId = destinationFolderId
			self.nameConflictPolicy = nameConflictPolicy
		}
		
		public func createCommand() -> Call.Command {
			var parameters: [Call.Command.Parameter] = [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "folderid", value: folderId),
				.number(name: "tofolderid", value: destinationFolderId)
			]
			
			switch nameConflictPolicy {
			case .overwrite: break
			case .skip: parameters.append(.boolean(name: "skipexisting", value: true))
			case .fail: parameters.append(.boolean(name: "noover", value: true))
			}
			
			return Call.Command(name: "copyfolder", parameters: parameters)
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Folder.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FolderMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to copying a folder.
		public enum Error: Int {
			/// A file with the same name already exists at the same level in the destination tree.
			/// Can only be returned when conflict policy is `NameConflictPolicy.fail`.
			case fileAlreadyExists = 2004
		}
	}
	
	
	/// Deletes a folder tree.
	public struct DeleteFolderRecursive: PCloudAPIMethod {
		/// The unique identifier of the root of the folder tree to delete.
		public let folderId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter folderId: The unique identifier of the root of the folder tree to delete.
		public init(folderId: UInt64) {
			self.folderId = folderId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "deletefolderrecursive", parameters: [
				.number(name: "folderid", value: folderId)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Void, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				return .success(())
			}
		}
		
		/// Errors specific to deleting a folder tree.
		public enum Error: Int {
			/// The folder does not exist.
			case folderDoesNotExist = 2005
			/// The root folder cannot be deleted.
			case cannotDeleteRootFolder = 2007
		}
	}
}


// MARK:- Methods related to file operations.

extension PCloudAPI {
	/// Creates a file from the body of this method and returns its metadata.
	public struct UploadFile: PCloudAPIMethod {
		/// The name of the file.
		public let name: String
		/// The unique identifier of the parent folder.
		public let parentFolderId: UInt64
		/// The date to use as the modification date for the file when creating it in the file system. When `nil` the file will be created
		/// with the current date as the modification date.
		public let modificationDate: Date?
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter name: A name for the file.
		/// - parameter parentFolderId: The unique identifier of the parent folder.
		/// - parameter modificationDate: The date to use as the modification date for the file when creating it in the file system.
		/// When `nil` the file will be created with the current date as the modification date.
		public init(name: String, parentFolderId: UInt64, modificationDate: Date?) {
			self.name = name
			self.parentFolderId = parentFolderId
			self.modificationDate = modificationDate
		}
		
		public func createCommand() -> Call.Command {
			var parameters: [Call.Command.Parameter] = [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "folderid", value: parentFolderId),
				.string(name: "filename", value: name),
				.boolean(name: "nopartial", value: true)
			]
			
			if let modificationDate = modificationDate {
				parameters.append(.number(name: "mtime", value: UInt64(modificationDate.timeIntervalSince1970)))
			}
			
			return Call.Command(name: "uploadfile", parameters: parameters)
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0["metadata"] as! [[String: Any]]
				return .success(try FileMetadataParser().parse(meta[0]))
			}
		}
		
		/// Errors specific to uploading a file.
		public enum Error: Int {
			/// The requested name is invalid.
			case invalidName = 2001
			/// The requested parent folder does not exist.
			case parentFolderDoesNotExist = 2005
		}
	}
	
	
	/// Creates an upload session which can be used to upload a file over several requests. Returns the identifier of the upload.
	public struct CreateUpload: PCloudAPIMethod {
		public var requiresAuthentication: Bool {
			return true
		}
		
		public init() {}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "upload_create", parameters: [])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<UInt64, PCloudAPI.Error<NullError>> {
			return { response in
				if let error = self.tryParseError(in: response) {
					return .failure(error)
				}
				
				return .success(response.uint64("uploadid"))
			}
		}
	}
	
	
	/// Fetches the state of an upload session.
	public struct GetUploadInfo: PCloudAPIMethod {
		/// The identifier of the upload session.
		public let uploadId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter uploadId: An upload session identifier.
		public init(uploadId: UInt64) {
			self.uploadId = uploadId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "upload_info", parameters: [.number(name: "uploadid", value: uploadId)])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<UploadInfo, PCloudAPI.Error<Error>> {
			return { response in
				if let error = self.tryParseError(in: response) {
					return .failure(error)
				}
				
				return .success(try UploadInfoParser().parse(response))
			}
		}
		
		public enum Error: Int {
			/// The provided upload identifier does not exist.
			case uploadIdDoesNotExist = 2067
		}
	}
	
	
	/// Writes data to an upload session.
	public struct WriteToUpload: PCloudAPIMethod {
		/// The identifier of the upload session.
		public let uploadId: UInt64
		/// The offset at which to write data.
		public let offset: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter uploadId: An upload session identifier.
		/// - parameter offset: An offset at which to write data.
		public init(uploadId: UInt64, offset: UInt64) {
			self.uploadId = uploadId
			self.offset = offset
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "upload_write", parameters: [.number(name: "uploadid", value: uploadId),
																   .number(name: "uploadoffset", value: offset)])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Void, PCloudAPI.Error<Error>> {
			return { response in
				if let error = self.tryParseError(in: response) {
					return .failure(error)
				}
				
				return .success(())
			}
		}
		
		public enum Error: Int {
			/// The provided upload identifier does not exist.
			case uploadIdDoesNotExist = 2067
			case couldNotWriteToUpload = 2068
		}
	}
	
	
	/// Commits an upload session into a file and returns the created file metadata.
	public struct SaveUpload: PCloudAPIMethod {
		/// An action to take in the event of a file conflict during saving.
		/// A file conflict can occur when attempting to save a file in a directory
		/// where another file with the same name already exists.
		public enum ConflictResolutionPolicy {
			/// Change the name of the saved file by appending the conflict number to the file name stem until
			/// an available name is found.
			/// For example, when trying to save a file with the name "image.jpeg", the file might be saved
			/// as "image (1).jpeg", "image (2).jpeg" and so on.
			case rename
			
			/// Overwrite the existing file.
			case overwrite
			
			/// Overwrite the existing file only if its hash matches the one provided. If the hashes don't match, then
			/// save the file by appending "{CONFLICTED}" to the file name stem. If the resulting name produces
			/// a conflict, begin appending the conflict number to the file name stem until an available name is found.
			/// This can be usefil in cases where you want to avoid race conditions in which more than one client tries to
			/// modify the content of one file at the same time.
			case overwriteFileHashOrRename(UInt64)
		}
		
		/// The identifier of the upload session.
		public let uploadId: UInt64
		/// The identifier of the directory in which to save the file.
		public let parentFolderId: UInt64
		/// The name of the file. Note that the file might be saved with a different name depending on the conflict resolution policy.
		public let fileName: String
		/// The date to use as the modification date for the file when creating it in the file system. When `nil` the file will be created
		/// with the current date as the modification date.
		public let fileModificationDate: Date?
		/// The action to take when file conflict occurs during saving.
		public let conflictResolutionPolicy: ConflictResolutionPolicy
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter uploadId: An upload session identifier.
		/// - parameter parentFolderId: An identifier of the folder where to save the file.
		/// - parameter fileName: A file name.
		/// - parameter fileModificationDate: A date to use as the modification date for the file when creating it in the file system. When `nil`,
		/// the file will be created with the current date as the modification date.
		/// - parameter onConflict: An action to take if a file conflict occurs.
		public init(uploadId: UInt64, parentFolderId: UInt64, fileName: String, fileModificationDate: Date?, onConflict: ConflictResolutionPolicy) {
			self.uploadId = uploadId
			self.parentFolderId = parentFolderId
			self.fileName = fileName
			self.fileModificationDate = fileModificationDate
			self.conflictResolutionPolicy = onConflict
		}
		
		public func createCommand() -> Call.Command {
			var parameters: [Call.Command.Parameter] = [defaultIconFormatParameter,
														defaultTimeFormatParameter,
														.number(name: "uploadid", value: uploadId),
														.number(name: "folderid", value: parentFolderId),
														.string(name: "name", value: fileName)]
			
			if let date = fileModificationDate {
				parameters.append(.number(name: "mtime", value: UInt64(date.timeIntervalSince1970)))
			}
			
			switch conflictResolutionPolicy {
			case .rename:
				parameters.append(.boolean(name: "renameifexists", value: true))
				
			case .overwriteFileHashOrRename(let hash):
				parameters.append(.number(name: "ifhash", value: hash))
				
			case .overwrite:
				break
			}
			
			return Call.Command(name: "upload_save", parameters: parameters)
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return { response in
				if let error = self.tryParseError(in: response) {
					return .failure(error)
				}
				
				return .success(try FileMetadataParser().parse(response))
			}
		}
		
		public enum Error: Int {
			/// The requested name is invalid.
			case invalidName = 2001
			/// The requested parent folder does not exist.
			case parentFolderDoesNotExist = 2005
			/// The provided upload identifier does not exist.
			case uploadIdDoesNotExist = 2067
		}
	}
	
	
	/// Copies a file and returns its updated metadata.
	public struct CopyFile: PCloudAPIMethod {
		/// The unique identifier of the file to copy.
		public let fileId: UInt64
		/// The unique identifier of the destination folder.
		public let destinationFolderId: UInt64
		/// `true` if a name conflict should be resolved by overwriting the already existing file, `false` if this method
		/// should fail when a name conflict occurs.
		public let overwrite: Bool
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: A unique identifier of the file to copy.
		/// - parameter destinationFolderId: A unique identifier of the destination folder.
		/// - parameter overwrite: `true` to resolve a potential name conflict by overwriting the already existing file,
		/// `false` to fail if a name conflict occurs.
		public init(fileId: UInt64, destinationFolderId: UInt64, overwrite: Bool) {
			self.fileId = fileId
			self.destinationFolderId = destinationFolderId
			self.overwrite = overwrite
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "copyfile", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId),
				.number(name: "tofolderid", value: destinationFolderId),
				.boolean(name: "noover", value: !overwrite)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FileMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to copying a file.
		public enum Error: Int {
			/// The parent folder does not exist.
			case componentOfParentDirectoryDoesNotExist = 2002
			/// A file with the same name already exists.
			case fileAlreadyExists = 2004
			/// The requested file does not exist.
			case fileDoesNotExist = 2009
		}
	}
	
	/// Renames a file and returns its updated metadata.
	public struct RenameFile: PCloudAPIMethod {
		/// The unique identifier of the file to rename.
		public let fileId: UInt64
		/// The new name of the file.
		public let newName: String
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: The unique identifier of the file to rename.
		/// - parameter newName: A new name for the file.
		public init(fileId: UInt64, newName: String) {
			self.fileId = fileId
			self.newName = newName
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "renamefile", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId),
				.string(name: "toname", value: newName)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FileMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to renaming a file.
		public enum Error: Int {
			/// The requested name is invalid.
			case invalidName = 2001
			/// The requested file does not exist.
			case fileDoesNotExist = 2009
		}
	}
	
	/// Moves a file and returns its updated metadata.
	public struct MoveFile: PCloudAPIMethod {
		/// The unique identifier of the file to move.
		public let fileId: UInt64
		/// The unique identifier of the destination folder.
		public let destinationFolderId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: The unique identifier of the file to move.
		/// - parameter destinationFolderId: The unique identifier of the destination folder.
		public init(fileId: UInt64, destinationFolderId: UInt64) {
			self.fileId = fileId
			self.destinationFolderId = destinationFolderId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "renamefile", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId),
				.number(name: "tofolderid", value: destinationFolderId)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FileMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to moving a file.
		public enum Error: Int {
			/// The parent folder does not exist.
			case componentOfParentDirectoryDoesNotExist = 2002
			/// The requested destination folder does not exist.
			case folderDoesNotExist = 2005
			/// The requested file does not exist.
			case fileDoesNotExist = 2009
		}
	}
	
	/// Deletes a file and returns its metadata.
	public struct DeleteFile: PCloudAPIMethod {
		/// The unique identifier of the file to delete.
		public let fileId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: The unique identifier of the file to delete.
		public init(fileId: UInt64) {
			self.fileId = fileId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "deletefile", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId),
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FileMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to deleting a file.
		public enum Error: Int {
			/// The requested file does not exist.
			case fileDoesNotExist = 2009
		}
	}
	
	/// Returns metadata for a file.
	public struct GetFileMetadata: PCloudAPIMethod {
		/// The unique identifier of the file to get the metadata.
		public let fileId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: The unique identifier of the file to get the metadata.
		public init(fileId: UInt64) {
			self.fileId = fileId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "stat", parameters: [
				defaultIconFormatParameter,
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId),
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<File.Metadata, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let meta = $0.dictionary("metadata")
				return .success(try FileMetadataParser().parse(meta))
			}
		}
		
		/// Errors specific to getting the metadata of a file.
		public enum Error: Int {
			/// The requested name is invalid.
			case invalidName = 2001
		}
	}
	
	/// Generates and returns links to a file. The first link in the return value is considered the best for this client.
	public struct GetFileLink: PCloudAPIMethod {
		/// The unique identifier of the file to get a link to.
		public let fileId: UInt64
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: The unique identifier of the file to get a link to.
		public init(fileId: UInt64) {
			self.fileId = fileId
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "getfilelink", parameters: [
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<[FileLink.Metadata], PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				return .success(try FileLinkMetadataParser().parse($0))
			}
		}
		
		/// Errors specific to generating a link a to a file.
		public enum Error: Int {
			/// The requested file does not exist.
			case fileDoesNotExist = 2009
		}
	}
	
	/// Generates and returns links to a file's thumbnail. The first link in the return value is considered the best for this client.
	public struct GetThumbnailLink: PCloudAPIMethod {
		/// The unique identifier of the file to get a thumbnail link to.
		public let fileId: UInt64
		/// The requested size of the thumbnail.
		public let thumbnailSize: CGSize
		/// Whether to enforce `thumbnailSize` (`true`) by potentially cropping parts of the image, or to allow width or height
		/// (but not both) to be smaller than the requested size (`false`). Aspect ratio is always preserved.
		public let crop: Bool
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileId: The unique identifier of the file to get a thumbnail link to. Only files with `hasThumbnail` set to `true` can
		/// have thumbnails generated for them.
		/// - parameter thumbnailSize: The required size of the thumbnail. The width must be between 16 and 2048.
		///	The height must be between 16 and 1024. And both width and height must be divisible by either 4 or 5
		/// - parameter crop: Whether to enforce `thumbnailSize` by potentially cropping parts
		/// of the image (`true`), or to allow width or height (but not both) to be smaller than the requested size (`false`).
		/// Aspect ratio is always preserved.
		public init(fileId: UInt64, thumbnailSize: CGSize, crop: Bool) {
			self.fileId = fileId
			self.thumbnailSize = thumbnailSize
			self.crop = crop
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "getthumblink", parameters: [
				defaultTimeFormatParameter,
				.number(name: "fileid", value: fileId),
				.string(name: "size", value: PCloudAPI.formatThumbnailSize(thumbnailSize)),
				.boolean(name: "crop", value: crop)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<[FileLink.Metadata], PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				return .success(try FileLinkMetadataParser().parse($0))
			}
		}
		
		/// Errors specific to generating a thumbnail link.
		public enum Error: Int {
			/// A thumbnail cannot be generated for the requested file. This may be because `hasThumbnail` is not `true` for this file.
			case thumbnailCannotBeCreatedForThisFile = 1014
			/// The requested thumbnail size is invalid.
			case invalidThumbnailSize = 1015
			/// The requested file does not exist.
			case fileDoesNotExist = 2009
		}
	}
	
	/// Generates and returns links to thumbnails for multiple files. Logically equivalent to calling `GetThumbnailLink` multiple times.
	/// The return value is a dictionary mapping a file identifier to the result of acquiring thumbnail links for that file.
	/// All error codes and input parameters from `GetThumbnailLink` apply for this method as well.
	public struct GetThumbnailsLinks: PCloudAPIMethod {
		public typealias Value = [UInt64: Result<[FileLink.Metadata], PCloudAPI.Error<GetThumbnailLink.Error>>]
		public typealias Error = NullError
		
		public let fileIds: Set<UInt64>
		public let thumbnailSize: CGSize
		public let crop: Bool
		
		public var requiresAuthentication: Bool {
			return true
		}
		
		/// - parameter fileIds: The unique identifiers of the files to get thumbnail links to. Only files with `hasThumbnail` set to `true`
		/// can have thumbnails generated for them.
		/// - parameter thumbnailSize: The required size of each thumbnail. The width must be between 16 and 2048.
		///	The height must be between 16 and 1024. And both width and height must be divisible by either 4 or 5
		/// - parameter crop: Whether to enforce `thumbnailSize` by potentially cropping parts
		/// of the image (`true`), or to allow width or height (but not both) to be smaller than the requested size (`false`).
		/// Aspect ratio is always preserved.
		public init(fileIds: Set<UInt64>, thumbnailSize: CGSize, crop: Bool) {
			self.fileIds = fileIds
			self.thumbnailSize = thumbnailSize
			self.crop = crop
		}
		
		public func createCommand() -> Call.Command {
			return Call.Command(name: "getthumbslinks", parameters: [
				defaultTimeFormatParameter,
				.string(name: "fileids", value: fileIds.map { "\($0)" }.joined(separator: ",")),
				.string(name: "size", value: PCloudAPI.formatThumbnailSize(thumbnailSize)),
				.boolean(name: "crop", value: crop)
			])
		}
		
		public func createResponseParser() -> ([String : Any]) throws -> Result<Value, PCloudAPI.Error<Error>> {
			return {
				if let error = self.tryParseError(in: $0) {
					return .failure(error)
				}
				
				let thumbEntries = $0["thumbs"] as! [[String: Any]]
				var result: Value = [:]
				let parser = FileLinkMetadataParser()
				
				for entry in thumbEntries {
					let fileId = entry.uint64("fileid")
					
					if let error = PCloudAPI.Error<GetThumbnailLink.Error>(apiResponse: entry) {
						result[fileId] = .failure(error)
					} else {
						result[fileId] = .success(try parser.parse(entry))
					}
				}
				
				return .success(result)
			}
		}
	}
	
	// Formats a CGSize struct to a string in the format expected by the API. Used in thumbnail-related calls.
	private static func formatThumbnailSize(_ size: CGSize) -> String {
		return "\(Int(size.width))x\(Int(size.height))"
	}
}

/// A dummy RawRepresentable that cannot be initialized.
public struct NullError: RawRepresentable {
	public let rawValue: Int
	
	public init?(rawValue: Int) {
		return nil
	}
}


/// An object defining input and output for a call to the pCloud API.
public protocol PCloudAPIMethod {
	/// The type of the return value of a method.
	associatedtype Value
	/// The type of the object describing errors from this method.
	associatedtype Error: RawRepresentable where Error.RawValue == Int
	
	/// A block computing the return value of a method from an API response dictionary.
	typealias Parser = ([String: Any]) throws -> Result<Value, PCloudAPI.Error<Error>>
	
	/// `true` if a method requires authentication, `false` otherwise. Methods requiring authentication
	/// will have authentication data added to them before the actual network call.
	var requiresAuthentication: Bool { get }
	
	/// Creates and returns a parser for the response from an API call.
	///
	/// - returns: A block computing the return value of a method from an API response dictionary.
	func createResponseParser() -> Parser
	
	/// Creates and returns an API command for a method.
	///
	/// - returns: An API command.
	func createCommand() -> Call.Command
}


extension PCloudAPI.Error {
	/// Initializes an API error by parsing an API response.
	/// Initialization fails if the result code is 0.
	public init?(apiResponse: [String: Any]) {
		let resultCode = apiResponse.int("result")
		
		guard let error = PCloudAPI.Error<MethodError>(code: resultCode, message: apiResponse.stringOrNil("error")) else {
			return nil
		}
		
		self = error
	}
}

extension PCloudAPIMethod {
	public func tryParseError(in input: [String: Any]) -> PCloudAPI.Error<Self.Error>? {
		return PCloudAPI.Error<Self.Error>(apiResponse: input)
	}
}
