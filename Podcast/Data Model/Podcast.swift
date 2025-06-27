//
//  Podcast.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import Foundation
import FeedKit

struct Podcast: Codable, Equatable {

	let author: String
	let description: String
	let feedURL: String
	let title: String

	// Note: These are not loaded initially.
	let artwork: String
	let largeArtwork: String
	let trackCount: Int

	// MARK: -

	init(json: [String : Any]) {
		self.author = json["artistName"] as? String ?? ""
		self.title = json["trackName"] as? String ?? ""
		self.description = ""
		self.trackCount = json["trackCount"] as? Int ?? 0
		self.artwork = json["artworkUrl100"] as? String ?? ""
		self.feedURL = json["feedUrl"] as? String ?? ""
		self.largeArtwork = json["artworkUrl600"] as? String ?? ""
	}

	init?(item: RSSFeedItem) {
		// safety check the item properties
		guard let title = item.title,
			  let sourceURL = item.source?.value else {
			return nil
		}

		self.author = item.author ?? ""
		self.description = item.description ?? ""
		self.feedURL = sourceURL
		self.title = title

		// TODO: load these from the feed source
		self.artwork = ""
		self.largeArtwork = ""
		self.trackCount = 0
		// ----
	}

	var isValid: Bool {
		return (feedURL.isEmpty == false)
	}

	// MARK: - Equatable

	static func == (lhs: Self, rhs: Self) -> Bool {
		return (lhs.feedURL == rhs.feedURL) && (lhs.author == rhs.author) && (lhs.title == rhs.title)
	}

}
