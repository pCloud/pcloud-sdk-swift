//
//  OAuthWebView.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import UIKit
import WebKit

/// A concrete implementation of `OAuthAuthorizationFlowView` based on UIKit.
public final class WebViewControllerPresenterMobile: OAuthAuthorizationFlowView {
	private let presentingViewController: UIViewController
	
	/// Initializes a new presenter.
	///
	/// - parameter presentingViewController: A controller used to present a web view controller from.
	public init(presentingViewController: UIViewController) {
		self.presentingViewController = presentingViewController
	}
	
	public func presentWebView(url: URL, interceptNavigation: @escaping (URL) -> Bool, didCancel: @escaping () -> Void) {
		let controller = WebViewControllerMobile(address: url, redirectHandler: interceptNavigation, cancelHandler: didCancel)
		let navigationWrapper = UINavigationController(rootViewController: controller)
		presentingViewController.present(navigationWrapper, animated: true, completion: nil)
	}
	
	public func dismissWebView() {
		presentingViewController.dismiss(animated: true, completion: nil)
	}
}

/// A view controller with a web view and a cancel button in the navigation bar. It forwards its navigation actions and cancel button
/// taps to blocks. The controller does not allow the user to type an address. An initial address is instead provided to instances of this
/// class which is loaded when an instance is shown.
public final class WebViewControllerMobile: UIViewController {
	private let address: URL
	private let redirectHandler: (URL) -> Bool
	private let cancelHandler: () -> Void
	
	private var webView: WKWebView!
	private var activityIndicator = UIActivityIndicatorView(style: .gray) // Shown during initial page loading.
	private var errorLabel: UILabel! // Shown when a page loading error occurs.
	
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
		
		super.init(nibName: nil, bundle: nil)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Link to pCloud"
		
		view.backgroundColor = .white
		
		webView = WKWebView()
		webView.navigationDelegate = self
		view.addSubview(webView)
		
		view.addSubview(activityIndicator)
		
		errorLabel = UILabel()
		errorLabel.textAlignment = .center
		errorLabel.font = UIFont.systemFont(ofSize: 18)
		errorLabel.backgroundColor = .clear
		errorLabel.textColor = .black
		errorLabel.numberOfLines = 0
		view.addSubview(errorLabel)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		webView.frame = view.bounds
		activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
		errorLabel.frame = view.bounds.insetBy(dx: 10, dy: 10)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		showError(nil)
		setActivityIndicatorVisible(true)
		load(address)
	}
	
	private func load(_ url: URL) {
		let request = URLRequest(url: url)
		webView.load(request)
	}
	
	private func setActivityIndicatorVisible(_ visible: Bool) {
		if visible {
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
		}
		
		activityIndicator.isHidden = !visible
	}
	
	private func showError(_ message: String?) {
		errorLabel.text = message
		errorLabel.isHidden = message == nil
	}
}

extension WebViewControllerMobile: WKNavigationDelegate {
	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if let navigationAddress = navigationAction.request.url, redirectHandler(navigationAddress) {
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		setActivityIndicatorVisible(false)
	}
	
	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		setActivityIndicatorVisible(false)
		showError(error.localizedDescription)
	}
}

extension WebViewControllerMobile {
	@objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
		cancelHandler()
	}
}
