//
//  PCloudAPITests.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import XCTest
@testable import PCloudSDKSwift

final class PCloudAPITests: XCTestCase {
	let timeFormatParameter = Call.Command.Parameter.string(name: "timeformat", value: "timestamp")
	let iconFormatParameter = Call.Command.Parameter.string(name: "iconformat", value: "id")
	
	func validate(_ command: Call.Command, against expected: Call.Command) {
		XCTAssertEqual(command, expected, "invalid command")
	}
}

// MARK: - Command construction tests
extension PCloudAPITests {
	func testCreatesCorrectUserInfoCommand() {
		// When
		let command = PCloudAPI.UserInfo().createCommand()
		
		// Expect
		validate(command, against: userInfoCommand())
	}
	
	func testCreatesCorrectListFolderCommand() {
		// Given
		let folderId: UInt64 = 3
		let recursive = true
		
		// When
		let command = PCloudAPI.ListFolder(folderId: folderId, recursive: recursive).createCommand()
		
		// Expect
		validate(command, against: listFolderCommand(folderId: folderId, recursive: recursive))
	}
	
	func testCreatesCorrectCreateFolderCommand() {
		// Given
		let name = "fancy folder name"
		let folderId: UInt64 = 4
		
		// When
		let command = PCloudAPI.CreateFolder(name: name, parentFolderId: folderId).createCommand()
		
		// Expect
		validate(command, against: createFolderCommand(name: name, folderId: folderId))
	}
	
	func testCreatesCorrectRenameFolderCommand() {
		// Given
		let folderId: UInt64 = 43
		let name = "fancy folder name"
		
		// When
		let command = PCloudAPI.RenameFolder(folderId: folderId, newName: name).createCommand()
		
		// Expect
		validate(command, against: renameFolderCommand(folderId: folderId, name: name))
	}
	
	func testCreatesCorrectMoveFolderCommand() {
		// Given
		let folderId: UInt64 = 24
		let destinationFolderId: UInt64 = 42
		
		// When
		let command = PCloudAPI.MoveFolder(folderId: folderId, destinationFolderId: destinationFolderId).createCommand()
		
		// Expect
		validate(command, against: moveFolderCommand(folderId: folderId, destinationFolderId: destinationFolderId))
	}
	
	func testCreatesCorrectCopyFolderCommandWithConflictPolictyOverwrite() {
		// Given
		let folderId: UInt64 = 44
		let destinationFolderId: UInt64 = 99
		let conflictPolicy: PCloudAPI.CopyFolder.NameConflictPolicy = .overwrite
		
		// When
		let command = PCloudAPI.CopyFolder(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: conflictPolicy).createCommand()
		
		// Expect
		validate(command, against: copyFolderCommand(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: conflictPolicy))
	}
	
	func testCreatesCorrectCopyFolderCommandWithConflictPolicySkip() {
		// Given
		let folderId: UInt64 = 12
		let destinationFolderId: UInt64 = 34
		let conflictPolicy: PCloudAPI.CopyFolder.NameConflictPolicy = .skip
		
		// When
		let command = PCloudAPI.CopyFolder(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: conflictPolicy).createCommand()
		
		// Expect
		validate(command, against: copyFolderCommand(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: conflictPolicy))
	}
	
	func testCreatesCorrectCopyFolderCommandWithConflictPolicyFail() {
		// Given
		let folderId: UInt64 = 4
		let destinationFolderId: UInt64 = 66
		let conflictPolicy: PCloudAPI.CopyFolder.NameConflictPolicy = .fail
		
		// When
		let command = PCloudAPI.CopyFolder(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: conflictPolicy).createCommand()
		
		// Expect
		validate(command, against: copyFolderCommand(folderId: folderId, destinationFolderId: destinationFolderId, nameConflictPolicy: conflictPolicy))
	}
	
	func testCreatesCorrectDeleteFolderRecursiveCommand() {
		// Given
		let folderId: UInt64 = 42
		
		// When
		let command = PCloudAPI.DeleteFolderRecursive(folderId: folderId).createCommand()
		
		// Expect
		validate(command, against: deleteFolderRecursiveCommand(folderId: folderId))
	}
	
	func testCreatesCorrectUploadFileCommandWithoutModificationDate() {
		// Given
		let folderId: UInt64 = 3
		let name = "fancy file name"
		
		// When
		let command = PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: nil).createCommand()
		
		// Expect
		validate(command, against: uploadFileCommand(name: name, parentFolderId: folderId, modificationDate: nil))
	}
	
	func testCreatesCorrectUploadFileCommandWithModificationDate() {
		// Given
		let folderId: UInt64 = 534
		let name = "fancy file name"
		let date = Date()
		
		// When
		let command = PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: date).createCommand()
		
		// Expect
		validate(command, against: uploadFileCommand(name: name, parentFolderId: folderId, modificationDate: date))
	}
	
	func testCreatesCorrectUploadFileCommandWithModificationDateBefore1970() {
		// Given
		let folderId: UInt64 = 123
		let name = "the file name"
		let date = Date(timeIntervalSince1970: -1)
		
		// When
		let command = PCloudAPI.UploadFile(name: name, parentFolderId: folderId, modificationDate: date).createCommand()
		
		// Expect
		validate(command, against: uploadFileCommand(name: name, parentFolderId: folderId, modificationDate: date))
	}
	
	func testCreatesCorrectCopyFileCommand() {
		// Given
		let fileId: UInt64 = 54
		let folderId: UInt64 = 655
		let overwrite = true
		
		// When
		let command = PCloudAPI.CopyFile(fileId: fileId, destinationFolderId: folderId, overwrite: overwrite).createCommand()
		
		// Expect
		validate(command, against: copyFileCommand(fileId: fileId, destinationFolderId: folderId, overwrite: overwrite))
	}
	
	func testCreatesCorrectRenameFileCommand() {
		// Given
		let fileId: UInt64 = 23
		let name = "fancy new name"
		
		// When
		let command = PCloudAPI.RenameFile(fileId: fileId, newName: name).createCommand()
		
		// Expect
		validate(command, against: renameFileCommand(fileId: fileId, name: name))
	}
	
	func testCreatesCorrectMoveFileCommand() {
		// Given
		let fileId: UInt64 = 324
		let folderId: UInt64 = 42
		
		// When
		let command = PCloudAPI.MoveFile(fileId: fileId, destinationFolderId: folderId).createCommand()
		
		// Expect
		validate(command, against: moveFileCommand(fileId: fileId, destinationFolderId: folderId))
	}
	
	func testCreatesCorrectDeleteFileCommand() {
		// Given
		let fileId: UInt64 = 324
		
		// When
		let command = PCloudAPI.DeleteFile(fileId: fileId).createCommand()
		
		// Expect
		validate(command, against: deleteFileCommand(fileId: fileId))
	}
	
	func testCreatesCorrectGetFileLinkCommand() {
		// Given
		let fileId: UInt64 = 453
		
		// When
		let command = PCloudAPI.GetFileLink(fileId: fileId).createCommand()
		
		// Expect
		validate(command, against: getFileLinkCommand(fileId: fileId))
	}
	
	func testCreatesCorrectGetThumbnailLinkCommand() {
		// Given
		let fileId: UInt64 = 453
		let thumbnailSize = CGSize(width: 200, height: 200)
		let crop = true
		
		// When
		let command = PCloudAPI.GetThumbnailLink(fileId: fileId, thumbnailSize: thumbnailSize, crop: crop).createCommand()
		
		// Expect
		validate(command, against: getThumbnailLinkCommand(fileId: fileId, thumbnailSize: thumbnailSize, crop: crop))
	}
	
	func testCreatesCorrectGetThumbnailsLinksCommand() {
		// Given
		let fileIds: Set<UInt64> = Set([1, 2, 3, 4])
		let thumbnailSize = CGSize(width: 200, height: 200)
		let crop = true
		
		// When
		let command = PCloudAPI.GetThumbnailsLinks(fileIds: fileIds, thumbnailSize: thumbnailSize, crop: crop).createCommand()
		
		// Expect
		validate(command, against: getThumbnailsLinksCommand(fileIds: fileIds, thumbnailSize: thumbnailSize, crop: crop))
	}
}


// MARK: - Commands
extension PCloudAPITests {
	func userInfoCommand() -> Call.Command {
		return Call.Command(name: "userinfo", parameters: [])
	}
	
	func listFolderCommand(folderId: UInt64, recursive: Bool) -> Call.Command {
		return Call.Command(name: "listfolder", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "folderid", value: folderId),
			.boolean(name: "recursive", value: recursive)
		])
	}
	
	func createFolderCommand(name: String, folderId: UInt64) -> Call.Command {
		return Call.Command(name: "createfolder", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.string(name: "name", value: name),
			.number(name: "folderid", value: folderId)
		])
	}
	
	func renameFolderCommand(folderId: UInt64, name: String) -> Call.Command {
		return Call.Command(name: "renamefolder", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "folderid", value: folderId),
			.string(name: "toname", value: name)
		])
	}
	
	func moveFolderCommand(folderId: UInt64, destinationFolderId: UInt64) -> Call.Command {
		return Call.Command(name: "renamefolder", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "folderid", value: folderId),
			.number(name: "tofolderid", value: destinationFolderId)
		])
	}
	
	func copyFolderCommand(folderId: UInt64, destinationFolderId: UInt64, nameConflictPolicy: PCloudAPI.CopyFolder.NameConflictPolicy) -> Call.Command {
		var parameters: [Call.Command.Parameter] = [
			timeFormatParameter,
			iconFormatParameter,
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
	
	func deleteFolderRecursiveCommand(folderId: UInt64) -> Call.Command {
		return Call.Command(name: "deletefolderrecursive", parameters: [
			.number(name: "folderid", value: folderId)
		])
	}
	
	func uploadFileCommand(name: String, parentFolderId: UInt64, modificationDate: Date?) -> Call.Command {
		var parameters: [Call.Command.Parameter] = [
			timeFormatParameter,
			iconFormatParameter,
			.string(name: "filename", value: name),
			.number(name: "folderid", value: parentFolderId),
			.boolean(name: "nopartial", value: true)
		]
		
		if let modificationDate = modificationDate {
			parameters.append(.number(name: "mtime", value: UInt64(clamping: modificationDate.timeIntervalSince1970)))
		}
		
		return Call.Command(name: "uploadfile", parameters: parameters)
	}
	
	func copyFileCommand(fileId: UInt64, destinationFolderId: UInt64, overwrite: Bool) -> Call.Command {
		return Call.Command(name: "copyfile", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "fileid", value: fileId),
			.number(name: "tofolderid", value: destinationFolderId),
			.boolean(name: "noover", value: !overwrite)
		])
	}
	
	func renameFileCommand(fileId: UInt64, name: String) -> Call.Command {
		return Call.Command(name: "renamefile", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "fileid", value: fileId),
			.string(name: "toname", value: name)
		])
	}
	
	func moveFileCommand(fileId: UInt64, destinationFolderId: UInt64) -> Call.Command {
		return Call.Command(name: "renamefile", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "fileid", value: fileId),
			.number(name: "tofolderid", value: destinationFolderId)
		])
	}
	
	func deleteFileCommand(fileId: UInt64) -> Call.Command {
		return Call.Command(name: "deletefile", parameters: [
			timeFormatParameter,
			iconFormatParameter,
			.number(name: "fileid", value: fileId)
		])
	}
	
	func getFileLinkCommand(fileId: UInt64) -> Call.Command {
		return Call.Command(name: "getfilelink", parameters: [
			timeFormatParameter,
			.number(name: "fileid", value: fileId)
		])
	}
	
	func getThumbnailLinkCommand(fileId: UInt64, thumbnailSize: CGSize, crop: Bool) -> Call.Command {
		return Call.Command(name: "getthumblink", parameters: [
			timeFormatParameter,
			.number(name: "fileid", value: fileId),
			.string(name: "size", value: "\(Int(thumbnailSize.width))x\(Int(thumbnailSize.height))"),
			.boolean(name: "crop", value: crop)
		])
	}
	
	func getThumbnailsLinksCommand(fileIds: Set<UInt64>, thumbnailSize: CGSize, crop: Bool) -> Call.Command {
		return Call.Command(name: "getthumbslinks", parameters: [
			timeFormatParameter,
			.string(name: "fileids", value: fileIds.map { "\($0)" }.joined(separator: ",")),
			.string(name: "size", value: "\(Int(thumbnailSize.width))x\(Int(thumbnailSize.height))"),
			.boolean(name: "crop", value: crop)
		])
	}
}
