//
//  Episode.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import FeedKit
import UIKit

struct Episode: Codable, Equatable {

	var date: String
	var description: String
	var artwork: String?
	var author: String?
	var title: String
	var url: String?

	// MARK: -

	init(feed: RSSFeedItem) {
		self.title = feed.title ?? ""
		self.description = feed.description ?? ""
		self.date = feed.pubDate?.formatDate() ?? ""
		self.url = feed.enclosure?.attributes?.url
		self.author = feed.iTunes?.iTunesAuthor
		self.artwork = feed.iTunes?.iTunesImage?.attributes?.href ?? ""
	}

	init(data: [String : Any]) {
		self.title = data["title"] as? String ?? "No Title"
		self.description = data["description"] as? String ?? ""

		let dateFormat = DateFormatter()
		dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS-HH:mm"
		self.date = dateFormat.date(from: data["published_at"] as! String)?.formatDate() ?? ""
		//self.date = data["published_at"] as? String ?? ""
		self.author = data["artist"] as? String ?? "Unknown"
		self.url = data["audio_url"] as? String ?? ""
		self.artwork = data["artwork_url"] as? String ?? ""
	}

	var isValid: Bool {
		return ((url != nil) && (url?.isEmpty == false))
	}

	// MARK: - Equatable

	static func == (lhs: Self, rhs: Self) -> Bool {
		return (lhs.url == rhs.url)
	}

}
