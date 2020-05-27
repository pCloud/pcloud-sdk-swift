//
//  AuthViewController.swift
//  Example_iOS
//
//  Created by Genislav Hristov on 12/29/16.
//  Copyright © 2016 pCloud. All rights reserved.
//

import UIKit
import PCloudSDKSwift

class AuthViewController: UIViewController {
	fileprivate let window: UIWindow
	fileprivate var authButton: UIButton!
	
	init(window: UIWindow) {
		self.window = window
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		authButton = UIButton(type: .system)
		authButton.setTitle("Authorize", for: .normal)
		authButton.titleLabel!.font = UIFont.systemFont(ofSize: 24)
		authButton.addTarget(self, action: #selector(didTapAuthorizeButton), for: .touchUpInside)
		view.addSubview(authButton)

        view.backgroundColor = .white
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		authButton.sizeToFit()
		authButton.center = view.center
	}
	
	@objc func didTapAuthorizeButton(_: UIButton) {
		PCloud.authorize(with: self) { result in
			if case .success(_) = result {
				self.switchToAccountContentInterface()
			}
		}
	}
	
	fileprivate func switchToAccountContentInterface() {
		let folderViewController = FolderTableViewController()
		window.rootViewController = UINavigationController(rootViewController: folderViewController)
	}
}
