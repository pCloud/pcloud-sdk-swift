//
//  AnyCancellationToken.swift
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

import Foundation
import libkern

/// Concrete type-erased implementation of `Cancellable`. It forwards its `cancel()` invocation to a block.
public final class AnyCancellationToken {
	// The block to call when cancel() is invoked.
	fileprivate var body: (() -> Void)?
	
	// Used for an atomic swap in cancel(). 0 indicates cancel() has not been called and 1 indicates otherwise.
	fileprivate var cancellationPredicate: Int32 = 0
	
	/// Creates a new token.
	///
	/// - parameter body: A block to forward the `cancel()` invocation to. The block is released when `cancel()` is invoked.
	public init(body: (() -> Void)? = nil) {
		self.body = body
	}
}

extension AnyCancellationToken: Cancellable {
	public var isCancelled: Bool {
		return cancellationPredicate != 0
	}
	
	public func cancel() {
		if !OSAtomicCompareAndSwap32Barrier(0, 1, &cancellationPredicate) {
			return
		}
		
		if let body = body {
			self.body = nil
			body()
		}
	}
}
