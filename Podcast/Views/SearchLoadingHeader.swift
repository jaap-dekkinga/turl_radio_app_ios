//
//  SearchLoadingHeader.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class SearchLoadingHeader: UIView {

	let label: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15.50, weight: .semibold)
		label.textColor = UIColor(named: "Item-Tertiary")
		label.textAlignment = .center
		label.numberOfLines = 0
		label.text = "Currently searching, please wait."
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let activity: UIActivityIndicatorView = {
		let activity = UIActivityIndicatorView(style: .large)
		activity.startAnimating()
		activity.translatesAutoresizingMaskIntoConstraints = false
		return activity
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate func setupActivityIndicatorView() {
		addSubview(activity)
		centerX(item: activity)
		centerY(item: activity, constant: -20)
	}

	fileprivate func setupLabel() {
		addSubview(label)
		centerX(item: label)
		label.topAnchor.constraint(equalTo: activity.bottomAnchor, constant: 5).isActive = true
	}
	
	fileprivate func setup() {
		setupActivityIndicatorView()
		setupLabel()
	}

}
