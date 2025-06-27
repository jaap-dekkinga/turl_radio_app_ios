//
//  AWS.swift
//  Podcast
//
//  Created by Gerrit on 6/16/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Foundation

struct AWSFeed {

	// static
	static let baseURL = "s3.us-east-2.amazonaws.com"
	static let feeds: [AWSFeed] = [
		AWSFeed(bucket: "tuneurl-choose-to-be-curious", feedURL: "https://feeds.soundcloud.com/users/soundcloud:users:193343495/sounds.rss")
	]

	// public
	let bucket: String
	let feedURL: String

	// MARK: - Static

	static func feed(for podcast: Podcast) -> AWSFeed? {
		for feed in feeds {
			if feed.feedURL == podcast.feedURL {
				return feed
			}
		}
		return nil
	}

	// MARK: - Public

	func url(for episode: Episode) -> URL? {
		// get the file name
		guard let episodeURL = episode.url,
			  let lastPathComponent = URL(string: episodeURL)?.lastPathComponent else {
			return nil
		}

		// create the aws bucket url
		let newURL = "https://\(bucket).\(AWSFeed.baseURL)/\(lastPathComponent)"

		return URL(string: newURL)
	}

}
