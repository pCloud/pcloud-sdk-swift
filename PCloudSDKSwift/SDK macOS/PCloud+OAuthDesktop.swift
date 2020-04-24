//
//  PCloud+OAuthDesktop.swift
//  SDK macOS
//
//  Created by Todor Pitekov on 22.04.20.
//  Copyright © 2020 pCloud LTD. All rights reserved.
//

import Foundation

extension PCloud {
	/// Starts the OAuth authorization flow. Expects `setUp()` to have been called. Call on the main thread.
	///
	/// - parameter controller: A view controller to present a web view from.
	/// - parameter completionBlock: A block called on the main thread when authorization completes or is cancelled.
	/// The global pCloud client will be initialized inside the block if authorization was successful.
	public static func authorize(controller: NSViewController, _ completionBlock: @escaping (OAuth.Result) -> Void) {
		authorize(with: WebViewControllerPresenterDesktop(presentingViewController: controller), completionBlock: completionBlock)
	}
}
