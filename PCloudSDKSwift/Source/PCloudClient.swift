//
//  PCloudClient.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2016 pCloud LTD. All rights reserved.
//

import Foundation

/// Wrapper around `ApiTaskController` providing convenient interface to common API methods.
public final class PCloudClient {
	/// The underlying task controller.
	public let controller: ApiTaskController
	
	/// Initializes a new instance.
	///
	/// - parameter controller: The controller that will create API tasks for this instance.
	public init(controller: ApiTaskController) {
		self.controller = controller
	}
}


// MARK:- User/Account-related methods.

public extension PCloudClient {
	/// Creates and returns a task for fetching user metadata.
	///
	/// - returns: A task producing a `User.Metadata` object on success.
	func fetchUserInfo() -> CallTask<PCloudApi.UserInfo> {
		return controller.call(PCloudApi.UserInfo())
	}
}


// MARK:- Folder operation methods.

public extension PCloudClient {
	/// Creates and returns a task for fetching folder metadata along with metadata of its contents.
	///
	/// - parameter folderId: The unique identifier of the folder to fetch.
	/// - parameter recursive: Pass `false` to fetch only the immediate children of the folder. Pass `true` to fetch the full folder tree of the folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func listFolder(_ folderId: UInt64, recursively recursive: Bool) -> CallTask<PCloudApi.ListFolder> {
		return controller.call(PCloudApi.ListFolder(folderId: folderId, recursive: recursive))
	}
	
	/// Creates and returns a task for creating a folder.
	///
	/// - parameter name: A name for the new folder.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func createFolder(named name: String, inFolder folderId: UInt64) -> CallTask<PCloudApi.CreateFolder> {
		return controller.call(PCloudApi.CreateFolder(name: name, parentFolderId: folderId))
	}
	
	/// Creates and returns a task for renaming a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to rename.
	/// - parameter newName: The new name for the folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func renameFolder(_ folderId: UInt64, to newName: String) -> CallTask<PCloudApi.RenameFolder> {
		return controller.call(PCloudApi.RenameFolder(folderId: folderId, newName: newName))
	}
	
	/// Creates and returns a task for moving a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to move.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func moveFolder(_ folderId: UInt64, toFolder destinationFolderId: UInt64) -> CallTask<PCloudApi.MoveFolder> {
		return controller.call(PCloudApi.MoveFolder(folderId: folderId, destinationFolderId: destinationFolderId))
	}
	
	/// Creates and returns a task for copying a folder.
	///
	/// - parameter folderId: The unique identifier of the folder to copy.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func copyFolder(_ folderId: UInt64,
	                toFolder destinationFolderId: UInt64,
	                onConflict nameConflictPolicy: PCloudApi.CopyFolder.NameConflictPolicy = .skip) -> CallTask<PCloudApi.CopyFolder> {
		return controller.call(PCloudApi.CopyFolder(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: nameConflictPolicy))
	}
	
	/// Creates and returns a task for deleting a folder along with all of its children recursively.
	///
	/// - parameter folderId: The unique identifier of the folder to delete.
	/// - returns: A task producing a `Folder.Metadata` object on success.
	func deleteFolderRecursively(_ folderId: UInt64) -> CallTask<PCloudApi.DeleteFolderRecursive> {
		return controller.call(PCloudApi.DeleteFolderRecursive(folderId: folderId))
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
	func upload(_ data: Data, toFolder folderId: UInt64, asFileNamed name: String, withModificationDate date: Date? = nil) -> UploadTask<PCloudApi.UploadFile> {
		return controller.upload(PCloudApi.UploadFile(name: name, parentFolderId: folderId, modificationDate: date), body: .data(data))
	}
	
	/// Creates and returns a task for uploading a file from a local file.
	///
	/// - parameter path: The local path of the file to upload.
	/// - parameter folderId: The unique identifier of the parent folder.
	/// - parameter name: A name for the file.
	/// - parameter date: The date to use as the modification date for the file when creating it in the file system. Passing `nil` will create the file
	/// with the current date as the modification date.
	/// - returns: A task producing a `File.Metadata` object on success.
	func upload(fromFileAt path: URL, toFolder folderId: UInt64, asFileNamed name: String, withModificationDate date: Date? = nil) -> UploadTask<PCloudApi.UploadFile> {
		return controller.upload(PCloudApi.UploadFile(name: name, parentFolderId: folderId, modificationDate: date), body: .file(path))
	}
	
	/// Creates and returns a task for copying a file.
	///
	/// - parameter fileId: The unique identifier of the file to copy.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - parameter overwrite: Whether to overwrite (`true`) a file with the same name in the destination folder, or to fail (`false`, the default).
	/// - returns: A task producing a `File.Metadata` object on success.
	func copyFile(_ fileId: UInt64, toFolder destinationFolderId: UInt64, overwrite: Bool = false) -> CallTask<PCloudApi.CopyFile> {
		return controller.call(PCloudApi.CopyFile(fileId: fileId, destinationFolderId: destinationFolderId, overwrite: overwrite))
	}
	
	/// Creates and returns a task for renaming a file.
	///
	/// - parameter fileId: The unique identifier of the file to rename.
	/// - parameter name: The new name for the file.
	/// - returns: A task producing a `File.Metadata` object on success.
	func renameFile(_ fileId: UInt64, to name: String) -> CallTask<PCloudApi.RenameFile> {
		return controller.call(PCloudApi.RenameFile(fileId: fileId, newName: name))
	}
	
	/// Creates and returns a task for moving a file.
	///
	/// - parameter fileId: The unique identifier of the file to move.
	/// - parameter destinationFolderId: The unique identifier of the destination folder.
	/// - returns: A task producing a `File.Metadata` object on success.
	func moveFile(_ fileId: UInt64, toFolder destinationFolderId: UInt64) -> CallTask<PCloudApi.MoveFile> {
		return controller.call(PCloudApi.MoveFile(fileId: fileId, destinationFolderId: destinationFolderId))
	}
	
	/// Creates and returns a task for deleting a file.
	///
	/// - parameter fileId: The unique identifier of the file to delete.
	/// - returns: A task producing a `File.Metadata` object on success.
	func deleteFile(_ fileId: UInt64) -> CallTask<PCloudApi.DeleteFile> {
		return controller.call(PCloudApi.DeleteFile(fileId: fileId))
	}
	
	/// Creates and returns a task for generating a link from which a file can be downloaded.
	///
	/// - parameter fileId: The unique identifier of the file.
	/// - returns: A task producing an `Array<FileLink.Metadata>` object on success.
	func getFileLink(forFile fileId: UInt64) -> CallTask<PCloudApi.GetFileLink> {
		return controller.call(PCloudApi.GetFileLink(fileId: fileId))
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
	func getThumbnailLink(forFile fileId: UInt64, thumbnailSize: CGSize, forceExactThumbnailSize: Bool = false) -> CallTask<PCloudApi.GetThumbnailLink> {
		return controller.call(PCloudApi.GetThumbnailLink(fileId: fileId, thumbnailSize: thumbnailSize, crop: forceExactThumbnailSize))
	}
	
	/// Creates and returns a task for generating thumbnail links for multiple files. Logically equivalent to calling `getThumbnailLink()` for multiple files.
	/// Only files with `hasThumbnail` set to `true` can have thumbnail links generated.
	///
	/// - parameter fileIds: A set of unique file identifiers to generate thumbnail links for.
	/// - parameter thumbnailSize: The required size of the thumbnail. The width must be between 16 and 2048.
	///	The height must be between 16 and 1024. And both width and height must be divisible by either 4 or 5
	/// - parameter forceExactThumbnailSize: Whether to enforce `thumbnailSize` (`true`) by potentially cropping parts
	/// of the images, or to allow width or height (but not both) to be smaller than the requested size. Aspect ratio is always preserved.
	/// - returns: A task producing a `Dictionary<UInt64, Result<Array<FileLink.Metadata>>>` object on success. The keys in the dictionary are the file
	/// identifiers passed as input to this method. Each file identifier is mapped against the result of aquiring a thumbnail link for that file.
	func getThumbnailLinks(forFiles fileIds: Set<UInt64>, thumbnailSize: CGSize, forceExactThumbnailSize: Bool = false) -> CallTask<PCloudApi.GetThumbnailsLinks> {
		return controller.call(PCloudApi.GetThumbnailsLinks(fileIds: fileIds, thumbnailSize: thumbnailSize, crop: forceExactThumbnailSize))
	}
	
	/// Creates and returns a task for downloading a file from a `URL`.
	///
	/// - parameter address: The resource address.
	/// - parameter destination: A block computing the download destination of the file from its temporary location. The block is referenced strongly
	/// by the task returned from this method and the thread on which it will be called is undefined.
	/// - returns: A task producing a `URL` on success which is the local path of the downloaded file.
	func downloadFile(from address: URL, to destination: @escaping (URL) -> URL) -> DownloadTask {
		let addressProvider: DownloadTask.AddressProvider = { completion in
			completion(.success(address))
			return VoidCancellationToken()
		}
		
		return controller.download(addressProvider: addressProvider, destination: destination)
	}
	
	/// Creates and returns a task for downloading a file from a file identifier.
	///
	/// - parameter fileId: The unique identifier of the file to download.
	/// - parameter destination: A block computing the download destination of the file from its temporary location. The block is referenced strongly
	/// by the task returned from this method and the thread on which it will be called is undefined.
	/// - returns: A task producing a `URL` on success which is the local path of the downloaded file.
	func downloadFile(_ fileId: UInt64, to destination: @escaping (URL) -> URL) -> DownloadTask {
		let addressProvider: DownloadTask.AddressProvider = { [weak self] completion in
			let task = self?.getFileLink(forFile: fileId).setCompletionBlock { result in
				switch result {
				case .success(let links): completion(.success(links[0].address))
				case .failure(let error): completion(.failure(error))
				}
			}.start()
			
			return AnyCancellationToken { task?.cancel() }
		}
		
		return controller.download(addressProvider: addressProvider, destination: destination)
	}
}
