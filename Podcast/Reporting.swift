//
//  Reporting.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/6/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Alamofire
import Foundation

class Reporting {

	// reporting actions
	enum Action: String {
		case started = "started"
		case disliked = "dislike"
		case liked = "liked"
		case loved = "loved"
		case bookmarked = "bookmarked"
		case shared = "shared"
	}

	struct Report: Codable {

		let action: String
		let podcastTitle: String?
		let podcastArtist: String?
		let podcastEpisode: String?
		let podcastTime: Double?
		let time: Double

		var podcastTimeString: String? {
			guard let podcastTime = self.podcastTime else {
				return nil
			}
			return Float64(podcastTime).formatDuration()
		}

		var timeString: String {
			let dateFormatter = DateFormatter()
			let timeZone = TimeZone(identifier: "UTC")
			dateFormatter.dateFormat = "YYYY-MM-dd'T'HHmm"
			dateFormatter.timeZone = timeZone
			return dateFormatter.string(from: Date(timeIntervalSince1970: time))
		}

		func isSamePodcast(as other: Report) -> Bool {
			return (self.podcastTitle == other.podcastTitle) && (self.podcastArtist == other.podcastArtist) && (self.podcastEpisode == other.podcastEpisode)
		}

	}

	// static
	static var shared = Reporting()

	// reporting server configuration
	private let serverHost = "pnz3vadc52.execute-api.us-east-2.amazonaws.com"
	private let serverPath = "/dev/createPodcastReport"

	// private
	private let reportingFileURL: URL
	private var previousReports = [Report]()

	// MARK: -

	private init() {
		// create the reporting file url
		reportingFileURL = AppDelegate.documentsURL.appendingPathComponent("Reporting.plist")
		// reload the previous reports
		reload()
	}

	// MARK: - Public

	func report(playerItem: PlayerItem, action: Action, time: Double = 0.0) {
		// create the report
		let report = Report(action: action.rawValue, podcastTitle: playerItem.podcast.title, podcastArtist: playerItem.podcast.author, podcastEpisode: playerItem.episode.title, podcastTime: time, time: Date().timeIntervalSince1970)

		if (action == .started) {
			// search the previous reports so we only report the start once
			if previousReports.contains(where: { ($0.action == Action.started.rawValue) && report.isSamePodcast(as: $0) }) {
				return
			} else {
				// add this report
				previousReports.append(report)
				save()
			}
		}

		// create the report data
		var reportData = [String : String]()
		reportData["action"] = report.action
		reportData["title"] = report.podcastTitle
		reportData["artist"] = report.podcastArtist
		reportData["episode"] = report.podcastEpisode
		reportData["season"] = "none"
		reportData["UUID"] = AppDelegate.uniqueID
		reportData["timestamp"] = report.podcastTimeString ?? ""

		// create the server url
		guard let serverURL = URL(string: ("https://" + serverHost + serverPath)) else {
			return
		}

		// perform the request
		Alamofire.request(serverURL, method: .post, parameters: reportData).response {
			(response) in
#if DEBUG
			if let responseData = response.data,
			   let responseString = String(data: responseData, encoding: .utf8) {
				print("report response: \(responseString)")
			} else {
				print("report response: [error]")
			}
#endif // DEBUG
		}
	}

	// MARK: - Private

	private func reload() {
		// load the reporting file
		guard let reportingData = try? Data(contentsOf: reportingFileURL) else {
			return
		}

		// decode the reporting data
		let decoder = PropertyListDecoder()
		guard let decodedItems = try? decoder.decode([Report].self, from: reportingData) else {
			NSLog("Reporting: Error reading previous reports.")
			return
		}

		// set the previous reports
		previousReports = decodedItems
	}

	private func save() {
		do {
			// save the previous reports
			let encoder = PropertyListEncoder()
			let reportingData = try encoder.encode(previousReports)
			try reportingData.write(to: reportingFileURL)
		} catch {
			NSLog("Reporting: Error writing previous reports. (\(error.localizedDescription))")
		}
	}

}
