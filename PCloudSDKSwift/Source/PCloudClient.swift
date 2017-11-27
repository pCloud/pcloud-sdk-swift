//
//  PCloudClient.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Wrapper around `APITaskController` providing convenient interface to common API methods.
public final class PCloudClient {
	/// The underlying task controller.
	public let controller: APITaskController
	
	/// Initializes a new instance.
	///
	/// - parameter controller: The controller that will create API tasks for this instance.
	public init(controller: APITaskController) {
		self.controller = controller
	}
}


// MARK:- User/Account-related methods.

public extension PCloudClient {
	/// Creates and returns a task for fetching user metadata.
	///
	/// - returns: A task producing a `User.Metadata` object on success.
	func fetchUserInfo() -> CallTask<PCloudAPI.UserInfo> {
		return controller.call(PCloudAPI.UserInfo())
	}
}


// MARK:- Folder operation methods.

public extension PCloudClient {
	/// Creates and returns a task for fetching folder metadata along with metadata of its contents.
	///
	/// - parameter folderId: The unique identifier of the folder to fetch.
	/// - parameter recursive: Pass `false` to fetch only the immediate children of the folder. Pass `true` to fetch the full folder tree of the folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func listFolder(_ folderId: UInt64, recursively recursive: Bool) -> CallTask<PCloudAPI.ListFolder> {
		return controller.call(PCloudAPI.ListFolder(folderId: folderId, recursive: recursive))
	}
	
	/// Creates and returns a task for creating a folder.
	///
	/// - parameter name: A name for the new folder.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func createFolder(named name: String, inFolder folderId: UInt64) -> CallTask<PCloudAPI.CreateFolder> {
		return controller.call(PCloudAPI.CreateFolder(name: name, parentFolderId: folderId))
	}
	
	/// Creates and returns a task for renaming a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to rename.
	/// - parameter newName: The new name for the folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func renameFolder(_ folderId: UInt64, to newName: String) -> CallTask<PCloudAPI.RenameFolder> {
		return controller.call(PCloudAPI.RenameFolder(folderId: folderId, newName: newName))
	}
	
	/// Creates and returns a task for moving a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to move.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func moveFolder(_ folderId: UInt64, toFolder destinationFolderId: UInt64) -> CallTask<PCloudAPI.MoveFolder> {
		return controller.call(PCloudAPI.MoveFolder(folderId: folderId, destinationFolderId: destinationFolderId))
	}
	
	/// Creates and returns a task for copying a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to copy.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func copyFolder(_ folderId: UInt64,
	                toFolder destinationFolderId: UInt64,
	                onConflict nameConflictPolicy: PCloudAPI.CopyFolder.NameConflictPolicy = .skip) -> CallTask<PCloudAPI.CopyFolder> {
		return controller.call(PCloudAPI.CopyFolder(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: nameConflictPolicy))
	}
	
	/// Creates and returns a task for deleting a folder along with all of its children recursively.
	///
	/// - parameter folderId: The unique identifier of the folder to delete.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func deleteFolderRecursively(_ folderId: UInt64) -> CallTask<PCloudAPI.DeleteFolderRecursive> {
		return controller.call(PCloudAPI.DeleteFolderRecursive(folderId: folderId))
	}
}


// MARK:- File operation methods.

public extension PCloudClient {
	/// Creates and returns a task for uploading a file from a `Data` object.
	///
	/// - parameter data: The data to upload.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - parameter name: A name for the file.
	/// - parameter date: The date to use as the modification date for the file when creating it in the file system. Passing `nil` will create the file
	/// with the current date as the modification date.
	/// - returns: A task producing a `File.Metadata` object on success.
	func upload(_ data: Data, toFolder folderId: UInt64, asFileNamed name: String, withModificationDate date: Date? = nil) -> UploadTask<PCloudAPI.UploadFile> {
		return controller.upload(PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: date), body: .data(data))
	}
	
	/// Creates and returns a task for uploading a file from a local file.
	///
	/// - parameter path: The local path of the file to upload.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - parameter name: A name for the file.
	/// - parameter date: The date to use as the modification date for the file when creating it in the file system. Passing `nil` will create the file
	/// with the current date as the modification date.
	/// - returns: A task producing a `File.Metadata` object on success.
	func upload(fromFileAt path: URL, toFolder folderId: UInt64, asFileNamed name: String, withModificationDate date: Date? = nil) -> UploadTask<PCloudAPI.UploadFile> {
		return controller.upload(PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: date), body: .file(path))
	}
	
	/// Creates and returns a task for copying a file.
	///
	/// - parameter fileId: The unique identifier of the file to copy.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - parameter overwrite: Whether to overwrite (`true`) a file with the same name in the destination folder, or to fail (`false`, the default).
	/// - returns: A task producing a `File.Metadata` object on success.
	func copyFile(_ fileId: UInt64, toFolder destinationFolderId: UInt64, overwrite: Bool = false) -> CallTask<PCloudAPI.CopyFile> {
		return controller.call(PCloudAPI.CopyFile(fileId: fileId, destinationFolderId: destinationFolderId, overwrite: overwrite))
	}
	
	/// Creates and returns a task for renaming a file.
	///
	/// - parameter fileId: The unique identifier of the file to rename.
	/// - parameter name: The new name for the file.
	/// - returns: A task producing a `File.Metadata` object on success.
	func renameFile(_ fileId: UInt64, to name: String) -> CallTask<PCloudAPI.RenameFile> {
		return controller.call(PCloudAPI.RenameFile(fileId: fileId, newName: name))
	}
	
	/// Creates and returns a task for moving a file.
	///
	/// - parameter fileId: The unique identifier of the file to move.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `File.Metadata` object on success.
	func moveFile(_ fileId: UInt64, toFolder destinationFolderId: UInt64) -> CallTask<PCloudAPI.MoveFile> {
		return controller.call(PCloudAPI.MoveFile(fileId: fileId, destinationFolderId: destinationFolderId))
	}
	
	/// Creates and returns a task for deleting a file.
	///
	/// - parameter fileId: The unique identifier of the file to delete.
	/// - returns: A task producing a `File.Metadata` object on success.
	func deleteFile(_ fileId: UInt64) -> CallTask<PCloudAPI.DeleteFile> {
		return controller.call(PCloudAPI.DeleteFile(fileId: fileId))
	}
	
	/// Creates and returns a task for generating a link from which a file can be downloaded.
	///
	/// - parameter fileId: The unique identifier of the file.
	/// - returns: A task producing an `Array<FileLink.Metadata>` object on success.
	func getFileLink(forFile fileId: UInt64) -> CallTask<PCloudAPI.GetFileLink> {
		return controller.call(PCloudAPI.GetFileLink(fileId: fileId))
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
	func getThumbnailLink(forFile fileId: UInt64, thumbnailSize: CGSize, forceExactThumbnailSize: Bool = false) -> CallTask<PCloudAPI.GetThumbnailLink> {
		return controller.call(PCloudAPI.GetThumbnailLink(fileId: fileId, thumbnailSize: thumbnailSize, crop: forceExactThumbnailSize))
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
	func getThumbnailLinks(forFiles fileIds: Set<UInt64>, thumbnailSize: CGSize, forceExactThumbnailSize: Bool = false) -> CallTask<PCloudAPI.GetThumbnailsLinks> {
		return controller.call(PCloudAPI.GetThumbnailsLinks(fileIds: fileIds, thumbnailSize: thumbnailSize, crop: forceExactThumbnailSize))
	}
	
	/// Creates and returns a task for downloading a file from a `URL`.
	///
	/// - parameter address: The resource address.
	/// - parameter destination: A block called with the temporary location of the downloaded file on disk.
	/// The block must either move or open the file for reading before it returns, otherwise the file gets deleted.
	/// The block should return the new location of the file.
	/// - returns: A task producing a `URL` on success which is the local path of the downloaded file.
	func downloadFile(from address: URL, to destination: @escaping (URL) throws -> URL) -> DownloadTask {
		return controller.download(from: address, to: destination)
	}
}
