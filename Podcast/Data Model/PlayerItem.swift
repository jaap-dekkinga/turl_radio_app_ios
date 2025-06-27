//
//  PlayerItem.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/6/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Foundation

struct PlayerItem: Codable, Equatable {

	var episode: Episode
	var podcast: Podcast

	// MARK: -

	var displayAuthor: String {
		if let author = episode.author {
			return author
		} else if (podcast.author.isEmpty == false) {
			return podcast.author
		}
		return podcast.title
	}

	var displayTitle: String {
		return episode.title
	}

	var isValid: Bool {
		return (podcast.isValid && episode.isValid)
	}

	// MARK: - Equatable

	static func == (lhs: Self, rhs: Self) -> Bool {
		return (lhs.podcast == rhs.podcast) && (lhs.episode == rhs.episode)
	}

}
