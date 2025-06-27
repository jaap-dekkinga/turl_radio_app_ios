//
//  Bookmarks.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/17/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import Foundation

class Bookmarks {

	// static
	static let changedNotification = NSNotification.Name("BookmarksChanged")
	static var shared = Bookmarks()

	// public
	var bookmarks = [Bookmark]()

	// private
	private let bookmarksFileURL: URL

	// MARK: -

	init() {
		// create the bookmarks file url
		bookmarksFileURL = AppDelegate.documentsURL.appendingPathComponent("Bookmarks.plist")
		// reload the bookmarks
		reloadBookmarks()
	}

	// MARK: - Public

	func addBookmark(playerItem: PlayerItem, time: Double) {
		// safety check
		guard playerItem.isValid, (time >= 0.0) else {
			return
		}

		// create the new bookmark
		let bookmark = Bookmark(episode: playerItem.episode, podcast: playerItem.podcast, time: time)
		bookmarks.append(bookmark)

		// save the bookmarks file
		saveBookmarks()

		// post the update notification
		NotificationCenter.default.post(name: Bookmarks.changedNotification, object: nil)
	}

	func removeBookmark(at index: Int) {
		// safety check
		guard (index < bookmarks.count) else {
			return
		}

		// remove the bookmark
		bookmarks.remove(at: index)

		// save the bookmarks file
		saveBookmarks()

		// post the update notification
		NotificationCenter.default.post(name: Bookmarks.changedNotification, object: nil)
	}

	// MARK: - Private

	private func reloadBookmarks() {
		// load the bookmarks file
		guard let bookmarksData = try? Data(contentsOf: bookmarksFileURL) else {
			return
		}

		// decode the bookmarks
		let decoder = PropertyListDecoder()
		guard let decodedItems = try? decoder.decode([Bookmark].self, from: bookmarksData) else {
			NSLog("Bookmarks: Error reading bookmarks file.")
			return
		}

		// set the bookmarks
		bookmarks = decodedItems
	}

	private func saveBookmarks() {
		do {
			// save the bookmarks
			let encoder = PropertyListEncoder()
			let bookmarksData = try encoder.encode(bookmarks)
			try bookmarksData.write(to: bookmarksFileURL)
		} catch {
			NSLog("Bookmarks: Error writing bookmarks file. (\(error.localizedDescription))")
		}
	}

}
