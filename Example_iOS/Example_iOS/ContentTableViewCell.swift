//
//  ContentTableViewCell.swift
//  Example_iOS
//
//  Created by Genislav Hristov on 12/30/16.
//  Copyright © 2016 pCloud. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
