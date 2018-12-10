//
//  LoadingTableViewCell.swift
//  Example_iOS
//
//  Created by Genislav Hristov on 12/30/16.
//  Copyright © 2016 pCloud. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
	let loadingIndicator = UIActivityIndicatorView(style: .gray)
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		initialize()
	}
	
	fileprivate func initialize() {
		loadingIndicator.color = .black
		contentView.addSubview(loadingIndicator)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		loadingIndicator.center = CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2)
	}
}
