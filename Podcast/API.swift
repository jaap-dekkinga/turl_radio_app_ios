//
//  API.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import Alamofire
import FeedKit
import Foundation

class API {

	static let shared = API()

	// Digital Podcast directory
	static let digitalPodcastAppID = "42753bb3eb6a7fcd4cb622f484acc0da"
    static let digitalPodcastBaseURL = "http://api.digitalpodcast.com/v2r"

	// private
	private let dataCache = NSCache<AnyObject, AnyObject>()
	private var useITunesDirectory = true

	// MARK: - Public

	func clearCache() {
		dataCache.removeAllObjects()
	}

	func getEpisodes(podcast: Podcast, completion: @escaping ([Episode]) -> Void) {
		// safety check
		guard (podcast.feedURL.isEmpty == false),
			  let feedURL = URL(string: podcast.feedURL) else {
			DispatchQueue.main.async {
				completion([])
			}
			return
		}

		// get the episodes from the cache
		if let result = dataCache.object(forKey: podcast.feedURL as AnyObject) as? RSSFeed {
			let episodes = parseEpisodes(feed: result, podcast: podcast)
			DispatchQueue.main.async {
				completion(episodes)
			}
			return
		}

		// parse the feed
		let parser = FeedParser(URL: feedURL)
		parser.parseAsync { [weak self] (result) in
			// safety check
			guard let self = self else {
				return
			}

			var episodes = [Episode]()

			switch result {
				case .success(let feed):
					if let rssFeed = feed.rssFeed {
						// save the feed in the cache
						self.dataCache.setObject(rssFeed as AnyObject, forKey: feedURL as AnyObject)
						// parse the episodes
						episodes = self.parseEpisodes(feed: rssFeed, podcast: podcast)
					}
				case .failure(let error):
					NSLog("Error parsing rss feed. (\(error.localizedDescription))")
			}

			DispatchQueue.main.async {
				completion(episodes)
			}
		}
	}

	func searchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> Void) {
		if useITunesDirectory {
			return searchITunes(searchText: searchText, completion: completion)
		} else {
			return searchDigitalPodcast(searchText: searchText, completion: completion)
		}
	}

	// MARK: - Private

	private func parseEpisodes(feed: RSSFeed, podcast: Podcast) -> [Episode] {
		// get the feed items
		guard let items = feed.items else {
			return []
		}

		var episodes = [Episode]()

		for item in items {
			var episode = Episode(feed: item)
			if (episode.artwork == nil) {
				episode.artwork = podcast.artwork
			}
			episodes.append(episode)
		}

		return episodes
	}

	private func searchDigitalPodcast(searchText: String, completion: @escaping ([Podcast]) -> Void) {
		// create the search url
		guard let searchString = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
			  let searchURL = URL(string: "\(API.digitalPodcastBaseURL)/search/?appid=\(API.digitalPodcastAppID)&format=rss&result=50&keywords=\(searchString)") else {
			NSLog("Error creating podcast search url.")
			return
		}

		// parse the rss feed
		let parser = FeedParser(URL: searchURL)
		parser.parseAsync { [weak self] (result) in
			// safety check
			guard (self != nil) else {
				return
			}

			var podcasts = [Podcast]()

			// get the results
			switch result {
				case .success(let feed):
					if let items = feed.rssFeed?.items {
						for item in items {
							if let podcast = Podcast(item: item) {
								podcasts.append(podcast)
							}
						}
					}
				case .failure(let error):
					NSLog("Error parsing rss feed. (\(error.localizedDescription))")
			}

			// call the completion handler
			DispatchQueue.main.async {
				completion(podcasts)
			}
		}
	}

	private func searchITunes(searchText: String, completion: @escaping ([Podcast]) -> Void) {
		let searchURL = "https://itunes.apple.com/search"

		Alamofire.request(searchURL, method: .get, parameters: ["term" : searchText], encoding: URLEncoding.queryString, headers: nil).responseJSON { (response) in

			// get the results
			guard let result = response.value as? [String : Any],
				  let resultCount = result["resultCount"] as? Int else {
				completion([])
				return
			}

			// parse the podcasts
			var podcasts = [Podcast]()

			if (resultCount > 0) {
				if let results = result["results"] as? [[String : Any]] {
					for item in results {
						if let kind = item["kind"] as? String {
							if (kind.lowercased() == "podcast") {
								podcasts.append(Podcast(json: item))
							}
						}
					}
				}
			}

			// call the completion handler
			DispatchQueue.main.async {
				completion(podcasts)
			}
		}
	}

}
