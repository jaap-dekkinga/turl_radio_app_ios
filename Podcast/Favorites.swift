//
//  Favorites.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/6/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Foundation

class Favorites {

	// static
	static let changedNotification = NSNotification.Name("FavoritesChanged")
	static var shared = Favorites()

	// public
	var favorites = [Favorite]()

	// private
	private let favoritesFileURL: URL

	// MARK: -

	private init() {
		// create the favorites file url
		favoritesFileURL = AppDelegate.documentsURL.appendingPathComponent("Favorites.plist")
		// reload the favorites
		reload()
	}

	// MARK: - Public

	func addFavorite(for podcast: Podcast) {
		// safety check
		guard favorites.contains(where: { $0.podcast == podcast }) == false else {
			return
		}

		// create the new favorite
		let favorite = Favorite(podcast: podcast)
		favorites.append(favorite)

		// save the favorites file
		save()

		// post the update notification
		NotificationCenter.default.post(name: Favorites.changedNotification, object: nil)
	}

	func isFavorite(_ podcast: Podcast) -> Bool {
		return (favorites.firstIndex(where: { $0.podcast == podcast }) != nil)
	}

	func removeFavorite(at index: Int) {
		// safety check
		guard (index < favorites.count) else {
			return
		}

		// remove the favorite
		favorites.remove(at: index)

		// save the favorites file
		save()

		// post the update notification
		NotificationCenter.default.post(name: Favorites.changedNotification, object: nil)
	}

	func removeFavorite(for podcast: Podcast) {
		// remove the favorite
		favorites.removeAll(where: { $0.podcast == podcast })

		// save the favorites file
		save()

		// post the update notification
		NotificationCenter.default.post(name: Favorites.changedNotification, object: nil)
	}

	// MARK: - Private

	private func reload() {
		// load the favorites file
		guard let favoritesData = try? Data(contentsOf: favoritesFileURL) else {
			return
		}

		// decode the favorites
		let decoder = PropertyListDecoder()
		guard let decodedItems = try? decoder.decode([Favorite].self, from: favoritesData) else {
			NSLog("Favorites: Error reading favorites file.")
			return
		}

		// set the favorites
		favorites = decodedItems
	}

	private func save() {
		do {
			// save the favorites
			let encoder = PropertyListEncoder()
			let favoritesData = try encoder.encode(favorites)
			try favoritesData.write(to: favoritesFileURL)
		} catch {
			NSLog("Favorites: Error writing favorites file. (\(error.localizedDescription))")
		}
	}

}
