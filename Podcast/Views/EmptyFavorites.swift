//
//  EmptyFavorites.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class EmptyFavorites: UICollectionReusableView {

	let label: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15.50, weight: .semibold)
		label.textColor = UIColor(named: "Item-Active")
		label.textAlignment = .center
		label.numberOfLines = 0
		label.text = "You have not favorited any podcasts."
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate func setup() {
		addSubview(label)
		label.fillSuperview(padding: 20)
	}

}
