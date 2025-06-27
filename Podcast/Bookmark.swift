//
//  Bookmark.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/17/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import Foundation

struct Bookmark: Codable {

	var episode: Episode
	var podcast: Podcast
	var time: Double

	// MARK: -

	var playerItem: PlayerItem {
		return PlayerItem(episode: episode, podcast: podcast)
	}

}
