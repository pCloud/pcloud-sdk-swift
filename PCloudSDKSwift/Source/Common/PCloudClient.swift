//
//  PCloudClient.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

/// Utility class providing convenient interface to common API methods.
public final class PCloudClient {
	/// The underlying builder responsible for creating call tasks.
	public let callTaskBuilder: PCloudAPICallTaskBuilder
	
	/// The underlying builder responsible for creating upload tasks.
	public let uploadTaskBuilder: PCloudAPIUploadTaskBuilder
	
	/// The underlying builder responsible for creating download tasks.
	public let downloadTaskBuilder: PCloudAPIDownloadTaskBuilder
	
	/// Initializes a new instance.
	///
	/// - parameter callTaskBuilder: Will be used to create call tasks.
	/// - parameter uploadTaskBuilder: Will be used to create upload tasks.
	/// - parameter downloadTaskBuilder: Will be used to create download tasks.
	public init(callTaskBuilder: PCloudAPICallTaskBuilder,
				uploadTaskBuilder: PCloudAPIUploadTaskBuilder,
				downloadTaskBuilder: PCloudAPIDownloadTaskBuilder) {
		self.callTaskBuilder = callTaskBuilder
		self.uploadTaskBuilder = uploadTaskBuilder
		self.downloadTaskBuilder = downloadTaskBuilder
	}
}


// MARK: - User/Account-related methods.

extension PCloudClient {
	/// Creates and returns a task for fetching user metadata.
	///
	/// - returns: A task producing a `User.Metadata` object on success.
	public func fetchUserInfo() -> CallTask<PCloudAPI.UserInfo> {
		return callTaskBuilder.createTask(for: PCloudAPI.UserInfo())
	}
}


// MARK: - Folder operation methods.

extension PCloudClient {
	/// Creates and returns a task for fetching folder metadata along with metadata of its contents.
	///
	/// - parameter folderId: The unique identifier of the folder to fetch.
	/// - parameter recursive: Pass `false` to fetch only the immediate children of the folder. Pass `true` to fetch the full folder tree of the folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	public func listFolder(_ folderId: UInt64, recursively recursive: Bool) -> CallTask<PCloudAPI.ListFolder> {
		return callTaskBuilder.createTask(for: PCloudAPI.ListFolder(folderId: folderId, recursive: recursive))
	}
	
	/// Creates and returns a task for creating a folder.
	///
	/// - parameter name: A name for the new folder.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	public func createFolder(named name: String, inFolder folderId: UInt64) -> CallTask<PCloudAPI.CreateFolder> {
		return callTaskBuilder.createTask(for: PCloudAPI.CreateFolder(name: name, parentFolderId: folderId))
	}
	
	/// Creates and returns a task for creating a folder if one with the same name doesn't already exist at the destination folder.
	/// - parameter name: A name for the new folder.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	@available(*, deprecated, message: "It will be removed in the next major version. Use createFolderIfDoesNotExist() instead.")
	public func createFolderIfNotExists(named name: String, inFolder folderId: UInt64) -> CallTask<PCloudAPI.CreateFolderIfNotExists> {
		return callTaskBuilder.createTask(for: PCloudAPI.CreateFolderIfNotExists(name: name, parentFolderId: folderId))
	}
	
	/// Creates and returns a task for creating a folder if one with the same name doesn't already exist at the destination folder.
	/// - parameter name: A name for the new folder.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - returns: A task producing a `PCloudAPI.CreateFolderIfDoesNotExist.Response` object on success.
	public func createFolderIfDoesNotExist(named name: String, inFolder folderId: UInt64) -> CallTask<PCloudAPI.CreateFolderIfDoesNotExist> {
		return callTaskBuilder.createTask(for: PCloudAPI.CreateFolderIfDoesNotExist(name: name, parentFolderId: folderId))
	}
	
	/// Creates and returns a task for renaming a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to rename.
	/// - parameter newName: The new name for the folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	public func renameFolder(_ folderId: UInt64, to newName: String) -> CallTask<PCloudAPI.RenameFolder> {
		return callTaskBuilder.createTask(for: PCloudAPI.RenameFolder(folderId: folderId, newName: newName))
	}
	
	/// Creates and returns a task for moving a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to move.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	public func moveFolder(_ folderId: UInt64, toFolder destinationFolderId: UInt64, newName: String? = nil) -> CallTask<PCloudAPI.MoveFolder> {
		let method = PCloudAPI.MoveFolder(folderId: folderId, destinationFolderId: destinationFolderId, newName: newName)
		return callTaskBuilder.createTask(for: method)
	}
	
	/// Creates and returns a task for copying a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to copy.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	public func copyFolder(_ folderId: UInt64,
						   toFolder destinationFolderId: UInt64,
						   onConflict nameConflictPolicy: PCloudAPI.CopyFolder.NameConflictPolicy = .skip) -> CallTask<PCloudAPI.CopyFolder> {
		let method = PCloudAPI.CopyFolder(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: nameConflictPolicy)
		return callTaskBuilder.createTask(for: method)
	}
	
	/// Creates and returns a task for deleting a folder along with all of its children recursively.
	///
	/// - parameter folderId: The unique identifier of the folder to delete.
	public func deleteFolderRecursively(_ folderId: UInt64) -> CallTask<PCloudAPI.DeleteFolderRecursive> {
		return callTaskBuilder.createTask(for: PCloudAPI.DeleteFolderRecursive(folderId: folderId))
	}
}


// MARK: - File operation methods.

extension PCloudClient {
	/// Creates and returns a task for uploading a file from a `Data` object.
	///
	/// - parameter data: The data to upload.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - parameter name: A name for the file.
	/// - parameter date: The date to use as the modification date for the file when creating it in the file system. Passing `nil` will create the file
	/// with the current date as the modification date.
	/// - returns: A task producing a `File.Metadata` object on success.
	public func upload(_ data: Data,
					   toFolder folderId: UInt64,
					   asFileNamed name: String,
					   withModificationDate date: Date? = nil) -> UploadTask<PCloudAPI.UploadFile> {
		let method = PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: date)
		return uploadTaskBuilder.createTask(for: method, with: .data(data))
	}
	
	/// Creates and returns a task for uploading a file from a local file.
	///
	/// - parameter path: The local path of the file to upload.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - parameter name: A name for the file.
	/// - parameter date: The date to use as the modification date for the file when creating it in the file system. Passing `nil` will create the file
	/// with the current date as the modification date.
	/// - returns: A task producing a `File.Metadata` object on success.
	public func upload(fromFileAt path: URL,
					   toFolder folderId: UInt64,
					   asFileNamed name: String,
					   withModificationDate date: Date? = nil) -> UploadTask<PCloudAPI.UploadFile> {
		let method = PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: date)
		return uploadTaskBuilder.createTask(for: method, with: .file(path))
	}
	
	/// Creates and returns a task for creating an upload session. The upload identifier produced by this method can be used to
	/// upload a file over multiple requests.
	///
	/// - returns: A task producing an upload identifier (`UInt64` value) on success.
	public func createUpload() -> CallTask<PCloudAPI.CreateUpload> {
		return callTaskBuilder.createTask(for: PCloudAPI.CreateUpload())
	}
	
	/// Creates and returns a task for fetching the current state of an upload session.
	///
	/// - parameter uploadId: An upload identifier.
	/// - returns: A task producing an `UploadInfo` instance on success.
	public func getUploadInfo(forUpload uploadId: UInt64) -> CallTask<PCloudAPI.GetUploadInfo> {
		return callTaskBuilder.createTask(for: PCloudAPI.GetUploadInfo(uploadId: uploadId))
	}
	
	/// Creates and returns a task for writing the data of a local file to an upload session.
	///
	/// - parameter path: The local path of the file to upload.
	/// - parameter uploadId: An upload identifier.
	/// - parameter offset: The upload session offset at which to start writing.
	public func upload(fromFileAt path: URL, toUpload uploadId: UInt64, atOffset offset: UInt64) -> UploadTask<PCloudAPI.WriteToUpload> {
		return uploadTaskBuilder.createTask(for: PCloudAPI.WriteToUpload(uploadId: uploadId, offset: offset), with: .file(path))
	}
	
	/// Creates and returns a task for writing a `Data` instance to an upload session.
	///
	/// - parameter data: The data to write.
	/// - parameter uploadId: An upload identifier.
	/// - parameter offset: The upload session offset at which to start writing.
	public func upload(_ data: Data, toUpload uploadId: UInt64, atOffset offset: UInt64) -> UploadTask<PCloudAPI.WriteToUpload> {
		return uploadTaskBuilder.createTask(for: PCloudAPI.WriteToUpload(uploadId: uploadId, offset: offset), with: .data(data))
	}
	
	/// Creates and returns a task for save an upload session as a file in the file system.
	///
	/// - parameter id: An identifier of the upload session to save.
	/// - parameter parentFolderId: The identifier folder in which to save the file.
	/// - parameter name: The file name to use when saving. Note this might change depending on the conflict resolution.
	/// - parameter onConflict: An action to take if a file conflict occurs. Please see `PCloudAPI.SaveUpload` for more info.
	/// - returns: A task producing a `File.Metadata` instance on success.
	public func saveUpload(id: UInt64,
						   toFolder parentFolderId: UInt64,
						   asFileNamed name: String,
						   withModificationDate date: Date? = nil,
						   onConflict: PCloudAPI.SaveUpload.ConflictResolutionPolicy) -> CallTask<PCloudAPI.SaveUpload> {
		let method = PCloudAPI.SaveUpload(uploadId: id,
										  parentFolderId: parentFolderId,
										  fileName: name,
										  fileModificationDate: date,
										  onConflict: onConflict)
		
		return callTaskBuilder.createTask(for: method)
	}
	
	/// Creates and returns a task for copying a file.
	///
	/// - parameter fileId: The unique identifier of the file to copy.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - parameter overwrite: Whether to overwrite (`true`) a file with the same name in the destination folder, or to fail (`false`, the default).
	/// - returns: A task producing a `File.Metadata` object on success.
	public func copyFile(_ fileId: UInt64, toFolder destinationFolderId: UInt64, overwrite: Bool = false) -> CallTask<PCloudAPI.CopyFile> {
		return callTaskBuilder.createTask(for: PCloudAPI.CopyFile(fileId: fileId, destinationFolderId: destinationFolderId, overwrite: overwrite))
	}
	
	/// Creates and returns a task for renaming a file.
	///
	/// - parameter fileId: The unique identifier of the file to rename.
	/// - parameter name: The new name for the file.
	/// - returns: A task producing a `File.Metadata` object on success.
	public func renameFile(_ fileId: UInt64, to name: String) -> CallTask<PCloudAPI.RenameFile> {
		return callTaskBuilder.createTask(for: PCloudAPI.RenameFile(fileId: fileId, newName: name))
	}
	
	/// Creates and returns a task for moving a file.
	///
	/// - parameter fileId: The unique identifier of the file to move.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `File.Metadata` object on success.
	public func moveFile(_ fileId: UInt64, toFolder destinationFolderId: UInt64, newName: String? = nil) -> CallTask<PCloudAPI.MoveFile> {
		let method = PCloudAPI.MoveFile(fileId: fileId, destinationFolderId: destinationFolderId, newName: newName)
		return callTaskBuilder.createTask(for: method)
	}
	
	/// Creates and returns a task for deleting a file.
	///
	/// - parameter fileId: The unique identifier of the file to delete.
	/// - returns: A task producing a `File.Metadata` object on success.
	public func deleteFile(_ fileId: UInt64) -> CallTask<PCloudAPI.DeleteFile> {
		return callTaskBuilder.createTask(for: PCloudAPI.DeleteFile(fileId: fileId))
	}
	
	/// Creates and returns a task for getting the metadata of a file.
	///
	/// - parameter fileId: The unique identifier of the file to get the metadata.
	/// - returns: A task producing a `File.Metadata` object on success.
	public func getFileMetadata(_ fileId: UInt64) -> CallTask<PCloudAPI.Stat> {
		return callTaskBuilder.createTask(for: PCloudAPI.Stat(fileId: fileId))
	}
	
	/// Creates and returns a task for generating a link from which a file can be downloaded.
	///
	/// - parameter fileId: The unique identifier of the file.
	/// - returns: A task producing an `Array<FileLink.Metadata>` object on success.
	public func getFileLink(forFile fileId: UInt64) -> CallTask<PCloudAPI.GetFileLink> {
		return callTaskBuilder.createTask(for: PCloudAPI.GetFileLink(fileId: fileId))
	}
	
	/// Creates and returns a task for generating a link from which a thumbnail for a file can be downloaded. Only files with `hasThumbnail` set to `true`
	/// can have thumbnail links generated.
	///
	/// - parameter fileId: The unique identifier of the file.
	/// - parameter thumbnailSize: The required size of the thumbnail. The width must be between 16 and 2048.
	///	The height must be between 16 and 1024. And both width and height must be divisible by either 4 or 5
	/// - parameter forceExactThumbnailSize: Whether to enforce `thumbnailSize` (`true`) by potentially cropping parts
	/// of the image, or to allow width or height (but not both) to be smaller than the requested size. Aspect ratio is always preserved.
	/// - returns: A task producing an `Array<FileLink.Metadata>` object on success.
	public func getThumbnailLink(forFile fileId: UInt64,
								 thumbnailSize: CGSize,
								 forceExactThumbnailSize: Bool = false) -> CallTask<PCloudAPI.GetThumbnailLink> {
		let method = PCloudAPI.GetThumbnailLink(fileId: fileId, thumbnailSize: thumbnailSize, crop: forceExactThumbnailSize)
		return callTaskBuilder.createTask(for: method)
	}
	
	/// Creates and returns a task for generating thumbnail links for multiple files. Logically equivalent to calling `getThumbnailLink()` for multiple files.
	/// Only files with `hasThumbnail` set to `true` can have thumbnail links generated.
	///
	/// - parameter fileIds: A set of unique file identifiers to generate thumbnail links for.
	/// - parameter thumbnailSize: The required size of the thumbnail. The width must be between 16 and 2048.
	///	The height must be between 16 and 1024. And both width and height must be divisible by either 4 or 5
	/// - parameter forceExactThumbnailSize: Whether to enforce `thumbnailSize` (`true`) by potentially cropping parts
	/// of the images, or to allow width or height (but not both) to be smaller than the requested size. Aspect ratio is always preserved.
	/// - returns: A task producing a `Dictionary<UInt64, Result<Array<FileLink.Metadata>, Error>>` object on success. The keys in the dictionary are the file
	/// identifiers passed as input to this method. Each file identifier is mapped against the result of aquiring a thumbnail link for that file.
	public func getThumbnailLinks(forFiles fileIds: Set<UInt64>,
								  thumbnailSize: CGSize,
								  forceExactThumbnailSize: Bool = false) -> CallTask<PCloudAPI.GetThumbnailsLinks> {
		let method = PCloudAPI.GetThumbnailsLinks(fileIds: fileIds, thumbnailSize: thumbnailSize, crop: forceExactThumbnailSize)
		return callTaskBuilder.createTask(for: method)
	}
	
	/// Creates and returns a task for downloading a file from a `URL`.
	///
	/// - parameter address: The resource address.
	/// - parameter downloadTag: To be passed alongside `FileLink.Metadata` resource addresses. Authenticates this client to the storage servers.
	/// - parameter destination: A block called with the temporary location of the downloaded file on disk.
	/// The block must either move or open the file for reading before it returns, otherwise the file gets deleted.
	/// The block should return the new location of the file.
	/// - returns: A task producing a `URL` on success which is the local path of the downloaded file.
	public func downloadFile(from address: URL, downloadTag: String? = nil, to destination: @escaping (URL) throws -> URL) -> DownloadTask {
		return downloadTaskBuilder.createTask(with: address, downloadTag: downloadTag, destination: destination)
	}
}
