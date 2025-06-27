//
//  TextTableViewHeader.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class TextTableViewHeader: UIView {

	let label: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15.50, weight: .semibold)
		label.textColor = UIColor(named: "Item-Active")
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()

	init(text: String) {
		super.init(frame: .zero)
		setup()
		label.text = text
	}

	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate func setup() {
		addSubview(label)
		label.fillSuperview(padding: 20)
	}

}
