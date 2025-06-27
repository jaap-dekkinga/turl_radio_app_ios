//
//  PodcastCell.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class PodcastCell: UITableViewCell {

	fileprivate let roundRadius: CGFloat = 5.0

	@IBOutlet weak var artworkImageView: UIImageView!
	@IBOutlet weak var infoLabel: UILabel!

	// MARK: -

	var podcast: Podcast? {
		didSet {
			if let podcast = podcast {
				artworkImageView.downloadImage(url: podcast.artwork)
				let attributedText = NSMutableAttributedString(attributedString: getString(text: podcast.title, font: 16.5, weight: .semibold, color: UIColor(named: "Item-Primary")!))
//				attributedText.append(getString(text: podcast.author + "\n", font: 14.25, weight: .regular, color: UIColor(named: "Item-Tertiary")!))
//				attributedText.append(getString(text: "\n", font: 5, weight: .regular, color: UIColor(named: "Item-Primary")!))
//				attributedText.append(getString(text: String(podcast.trackCount) + " Episode" + (podcast.trackCount == 1 ? "" : "s"), font: 13.25, weight: .regular, color: UIColor(named: "hotPurple")!))
				infoLabel.attributedText = attributedText
			}
		}
	}

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
		artworkImageView.layer.cornerRadius = roundRadius
	}

}
