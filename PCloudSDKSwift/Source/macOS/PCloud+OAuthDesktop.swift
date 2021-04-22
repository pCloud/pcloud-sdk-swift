//
//  PCloud+OAuthDesktop.swift
//  SDK macOS
//
//  Created by Todor Pitekov on 22.04.20.
//  Copyright © 2020 pCloud LTD. All rights reserved.
//

#if canImport(AppKit)

import AppKit

extension PCloud {
	/// Starts the OAuth authorization flow. Expects `setUp()` to have been called. Call on the main thread.
	///
	/// - parameter controller: A view controller to present a web view from. Must be in the view hierarchy.
	/// - parameter completionBlock: A block called on the main thread when authorization completes or is cancelled.
	/// The global pCloud client will be initialized inside the block if authorization was successful.
	public static func authorize(with controller: NSViewController, _ completionBlock: @escaping (OAuth.Result) -> Void) {
		if #available(OSX 10.15, *) {
			guard let window = controller.view.window else {
				assertionFailure("Cannot present from a view controller that is not part of the view hierarchy.")
				return
			}
			
			authorize(with: window, completionBlock: completionBlock)
		} else {
			authorize(with: WebViewControllerPresenterDesktop(presentingViewController: controller), completionBlock: completionBlock)
		}
	}
}

#endif
