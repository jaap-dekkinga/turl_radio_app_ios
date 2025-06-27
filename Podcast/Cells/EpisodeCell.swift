//
//  EpisodeCell.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

	fileprivate let roundRadius: CGFloat = 5.0

	// interface
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var episodeImage: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!

	// MARK: -

	var playerItem: PlayerItem? {
		didSet {
			if let playerItem = self.playerItem {
				titleLabel.text = playerItem.displayTitle
				timeLabel.text = playerItem.episode.date
				descriptionLabel.text = playerItem.episode.description.sanitizeHTML()
			} else {
				titleLabel.text = ""
				timeLabel.text = ""
				descriptionLabel.text = ""
			}
			if let imageURL = playerItem?.episode.artwork,
			   (imageURL.isEmpty == false) {
				episodeImage.downloadImage(url: imageURL)
			} else {
				episodeImage.image = UIImage(named: "blankPodcast")
			}
		}
	}

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
		episodeImage.layer.cornerRadius = roundRadius
	}

	// MARK: - Actions

	@IBAction func play(_ sender: AnyObject) {
		if let playerItem = self.playerItem {
			// play the item
			Player.shared.playList = [playerItem]
			Player.shared.currentPlaylistIndex = 0
			Player.shared.setPlayerItem(playerItem)
			Player.shared.maximizePlayer()
		}
	}

}
