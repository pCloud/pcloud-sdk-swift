//
//  OAuthWebViewDesktop.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Cocoa
import WebKit

/// A concrete implementation of `OAuthAuthorizationFlowView` based on AppKit.
public final class WebViewControllerPresenterDesktop: OAuthAuthorizationFlowView {
	private let presentingViewController: NSViewController
	private var webViewController: WebViewControllerDesktop? // The presented web view controller. Nil if no controller is presented currently.
	
	/// Initializes a new presenter.
	///
	/// - parameter presentingViewController: A controller used to present a web view controller from.
	public init(presentingViewController: NSViewController) {
		self.presentingViewController = presentingViewController
	}
	
	public func presentWebView(url: URL, interceptNavigation: @escaping (URL) -> Bool, didCancel: @escaping () -> Void) {
		let controller = WebViewControllerDesktop(address: url, redirectHandler: interceptNavigation, cancelHandler: didCancel)
		webViewController = controller
		presentingViewController.presentAsSheet(controller)
	}
	
	public func dismissWebView() {
		if let webViewController = webViewController {
			self.webViewController = nil
			presentingViewController.dismiss(webViewController)
		}
	}
}

/// A view controller with a web view and a cancel button. It forwards its navigation actions and cancel button
/// taps to blocks. The controller does not allow the user to type an address. An initial address is instead provided to instances of this
/// class which is loaded when an instance is shown.
public final class WebViewControllerDesktop: NSViewController {
	private let address: URL
	private let redirectHandler: (URL) -> Bool
	private let cancelHandler: () -> Void
	
	@IBOutlet var webViewContainer: BorderedView!
	@IBOutlet var progressIndicator: NSProgressIndicator! // Shown during initial page loading.
	@IBOutlet var errorLabel: NSTextField! // Shown when a page loading error occurs.
	
	private var webView: WKWebView!
	
	/// Initializes a new view controller with a web view.
	///
	/// - parameter address: The address of the page to open when the view controller is shown.
	/// - parameter redirectHandler: A block invoked when a navigation action is about to take place. Called with the
	/// destination address. The return value determines whether the controller should allow the redirect or not.
	/// - parameter cancelHandler: A block invoked when the user taps on the cancel button.
	public init(address: URL, redirectHandler: @escaping (URL) -> Bool, cancelHandler: @escaping () -> Void) {
		self.address = address
		self.redirectHandler = redirectHandler
		self.cancelHandler = cancelHandler
		
		// Try to find our .nib file in the following places:
		// - The PCloudSDKSwiftResources.bundle (will exists if we're managed by CocoaPods).
		// - Our parent bundle.
		// - The main bundle.
		
		let resourceBundle: Bundle = {
			let parentBundle = Bundle(for: WebViewControllerDesktop.self)
			
			if let resourceBundlePath = parentBundle.path(forResource: "PCloudSDKSwiftResources", ofType: "bundle") {
				return Bundle(path: resourceBundlePath)!
			}
			
			if let bundle = [parentBundle, .main].first(where: { $0.path(forResource: "WebViewControllerDesktop", ofType: "nib") != nil }) {
				return bundle
			}
			
			fatalError("Cannot find WebViewControllerDesktop.nib")
		}()
		
		super.init(nibName: "WebViewControllerDesktop", bundle: resourceBundle)
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredContentSize = view.bounds.size
		
		webViewContainer.borderWidth = 1
		webViewContainer.borderColor = .lightGray
		
		webView = WKWebView(frame: webViewContainer.bounds)
		webView.navigationDelegate = self
		webViewContainer.addSubview(webView, positioned: .below, relativeTo: nil)
		
		progressIndicator.controlTint = .graphiteControlTint
		
		setProgressIndicatorVisible(true)
		showError("")
		load(address)
	}
	
	private func load(_ url: URL) {
		let request = URLRequest(url: url)
		webView.load(request)
	}
	
	private func setProgressIndicatorVisible(_ visible: Bool) {
		if visible {
			progressIndicator.startAnimation(self)
		} else {
			progressIndicator.stopAnimation(self)
		}
		
		progressIndicator.isHidden = !visible
	}
	
	private func showError(_ message: String) {
		errorLabel.stringValue = message
		errorLabel.isHidden = message.isEmpty
	}
}

extension WebViewControllerDesktop: WKNavigationDelegate {
	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if let navigationAddress = navigationAction.request.url, redirectHandler(navigationAddress) {
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		setProgressIndicatorVisible(false)
	}
	
	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		setProgressIndicatorVisible(false)
		showError(error.localizedDescription)
	}
}

extension WebViewControllerDesktop {
	@IBAction func cancelButtonTapped(_ sender: NSButton) {
		cancelHandler()
	}
}

// A simple view with a border. Clients of the class can control border color and width. 
public final class BorderedView: NSView {
	public var borderWidth: CGFloat = 0 {
		didSet {
			if borderWidth != oldValue {
				needsDisplay = true
			}
		}
	}
	
	public var borderColor: NSColor? {
		didSet {
			if borderColor != oldValue {
				needsDisplay = true
			}
		}
	}
	
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		wantsLayer = true
	}
	
	public override var wantsUpdateLayer: Bool {
		return true
	}
	
	public override func updateLayer() {
		layer!.borderWidth = borderWidth
		layer!.borderColor = borderColor?.cgColor
	}
}
