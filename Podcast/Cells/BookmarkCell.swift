//
//  BookmarkCell.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/6/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import UIKit

class BookmarkCell: UITableViewCell {

	// interface
	@IBOutlet weak var episodeLabel: UILabel!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var podcastImage: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!

	// private
	private var currentBookmark: Bookmark?

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
		podcastImage.layer.cornerRadius = 8.0
	}

	func setBookmark(_ bookmark: Bookmark?) {
		currentBookmark = bookmark
		podcastImage.image = UIImage(named: "blankPodcast")
		if let bookmark = bookmark {
			podcastImage.downloadImage(url: bookmark.podcast.largeArtwork)
			titleLabel.text = bookmark.podcast.title
			episodeLabel.text = bookmark.episode.title
			timeLabel.text = Float64(bookmark.time).formatDuration()
		} else {
			// reset
			titleLabel.text = ""
			episodeLabel.text = ""
			timeLabel.text = "--:--"
		}
	}

	@IBAction func play(_ sender: AnyObject) {
		// get the player item
		guard let bookmark = currentBookmark else {
			return
		}

		// play the item
		Player.shared.playList = [bookmark.playerItem]
		Player.shared.currentPlaylistIndex = 0
		Player.shared.setPlayerItem(bookmark.playerItem, startTime: bookmark.time)
		Player.shared.maximizePlayer()
	}

}
