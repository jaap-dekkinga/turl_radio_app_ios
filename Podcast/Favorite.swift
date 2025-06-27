//
//  Favorite.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/6/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Foundation

struct Favorite: Codable, Equatable {

	var podcast: Podcast

	// MARK: - Equatable

	static func == (lhs: Self, rhs: Self) -> Bool {
		return (lhs.podcast == rhs.podcast)
	}

}
