//
//  FolderTableViewController.swift
//  Example_iOS
//
//  Created by Genislav Hristov on 12/29/16.
//  Copyright © 2016 pCloud. All rights reserved.
//

import UIKit
import PCloudSDKSwift

private let RootFolderId: UInt64 = 0
private let CellIdentifier = "FolderTableViewCell"

class FolderTableViewController: UITableViewController {
	fileprivate let folderId: UInt64
	fileprivate var folderMetadata: Folder.Metadata?
	fileprivate var listFolderTask: CallTask<PCloudAPI.ListFolder>?
	fileprivate var isPreparingContent: Bool = false
	fileprivate var error: Error?
	
	fileprivate lazy var loadingPlaceholderCell: UITableViewCell = {
		let cell = LoadingTableViewCell()
		cell.selectionStyle = .none
		cell.loadingIndicator.startAnimating()
		return cell
	}()
	
	fileprivate lazy var errorPlaceholderCell: UITableViewCell = {
		let cell = UITableViewCell()
		cell.selectionStyle = .none
		cell.textLabel!.textColor = .red
		cell.textLabel!.textAlignment = .center
		cell.textLabel!.numberOfLines = 2
		return cell
	}()
	
	init(folderId: UInt64 = RootFolderId) {
		self.folderId = folderId
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		updateTitle()
		
        listFolderTask = PCloud.sharedClient!.listFolder(folderId, recursively: false)
		listFolderTask!.addCompletionBlock { result in
			self.isPreparingContent = false
			
			switch result {
			case .success(let folderMetadata):
				self.folderMetadata = folderMetadata
				self.updateTitle()
			case .failure(let error):
				self.error = error
			}
			
			self.tableView.reloadData()
		}
		
		isPreparingContent = true
		listFolderTask!.start()
		
		tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		guard let task = listFolderTask else {
			return
		}
		
		if task.isCancelled {
			return
		}
		
		task.cancel()
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isPreparingContent || error != nil {
			return 1
		}
		
		guard let contents = folderMetadata?.contents else {
			return 0
		}
		
        return contents.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let error = error {
			return errorPlaceholderCell(error)
		}
		
		if isPreparingContent {
			return loadingPlaceholderCell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! ContentTableViewCell
		configureContentCell(cell, atIndexPath: indexPath)
		
		return cell
	}
	
	private func configureContentCell(_ cell: ContentTableViewCell, atIndexPath indexPath: IndexPath) {
		var name: String
		var detailText = ""
		var image: UIImage
		var selectionStyle: UITableViewCell.SelectionStyle = .default
		
		let content = folderMetadata!.contents[indexPath.row]
		
		if content.isFolder {
			name = content.folderMetadata!.name
			image = UIImage(named: "content_folder")!
		} else {
			let fileSize = content.fileMetadata!.size
			name = content.fileMetadata!.name
			detailText = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .binary)
			image = UIImage(named: "content_file")!
			selectionStyle = .none
		}
		
		cell.textLabel!.text = name
		cell.detailTextLabel!.text = detailText
		cell.imageView!.image = image
		cell.selectionStyle = selectionStyle
	}
	
	fileprivate func errorPlaceholderCell(_ error: Error) -> UITableViewCell {
		let cell = errorPlaceholderCell
		cell.textLabel!.text = "Error: \(error.localizedDescription)"
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let content = folderMetadata?.contents[indexPath.row] else {
			return
		}
		
		if content.isFolder {
			let controller = FolderTableViewController(folderId: content.folderMetadata!.id)
			navigationController?.pushViewController(controller, animated: true)
		}
	}
	
	fileprivate func updateTitle() {
		if RootFolderId == folderId {
			title = "PCloudSDK Example"
			return
		}
		
		title = folderMetadata?.name
	}
}
