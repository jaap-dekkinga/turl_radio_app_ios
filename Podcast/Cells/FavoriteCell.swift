//
//  FavoriteCell.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class FavoriteCell: UICollectionViewCell {

	// interface
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var podcastImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!

	// computed
	var podcast: Podcast? {
		didSet {
			if let podcast = podcast {
				titleLabel.text = podcast.title
				artistLabel.text = podcast.author
				podcastImage.downloadImage(url: podcast.largeArtwork)
			}
		}
	}

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
		podcastImage.layer.cornerRadius = 5.0
	}

}
