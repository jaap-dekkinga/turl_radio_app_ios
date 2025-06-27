//
//  EpisodesViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class EpisodesViewController: BaseTableViewController {

	// private
	private let cellId = "EpisodeCell"
	private let activity = UIActivityIndicatorView(style: .medium)
	private var downloadProgress: LoadingView!
	private var playerItems = [PlayerItem]()

	var podcast: Podcast? {
		didSet {
			if let podcast = podcast {
				navigationItem.title = podcast.title
				setupNavigationBarButtons(isFavorite: Favorites.shared.isFavorite(podcast))
				API.shared.getEpisodes(podcast: podcast) { [weak self] episodes in
					if let self = self {
						self.playerItems.removeAll()
						for episode in episodes {
							self.playerItems.append(PlayerItem(episode: episode, podcast: podcast))
						}
						DispatchQueue.main.async { [weak self] in
							self?.tableView.reloadData()
							self?.removeLoader()
						}
					}
				}
			}
		}
	}

	fileprivate func addLoader() {
		view.addSubview(activity)
		activity.fillSuperview()
		activity.startAnimating()
	}

	fileprivate func removeLoader() {
		view.removeConstraints(activity.constraints)
		activity.removeFromSuperview()
	}

	fileprivate func setupNavigationBarButtons(isFavorite: Bool) {
		let emptyHeart = UIBarButtonItem(image: UIImage(named: "Player-Love-Inactive"), style: .plain, target: self, action: #selector(addFavorite(_:)))
		emptyHeart.tintColor = UIColor(named: "Item-Primary")
		let filledHeart = UIBarButtonItem(image: UIImage(named: "Player-Love-Active"), style: .plain, target: self, action: #selector(removeFavorite(_:)))
		filledHeart.tintColor = UIColor(named: "Item-Favorite")
		navigationItem.rightBarButtonItem = isFavorite ? filledHeart : emptyHeart
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTable()
		addLoader()
	}

	// MARK: - Actions

	@objc func addFavorite(_ sender: AnyObject?) {
		// safety check
		guard let podcast = self.podcast else {
			return
		}

		Favorites.shared.addFavorite(for: podcast)
		setupNavigationBarButtons(isFavorite: true)
	}

	@objc func removeFavorite(_ sender: AnyObject?) {
		// safety check
		guard let podcast = self.podcast else {
			return
		}

		// remove the favorite
		Favorites.shared.removeFavorite(for: podcast)
		setupNavigationBarButtons(isFavorite: false)
	}

	// MARK: - Private

	fileprivate func addedToDownloads() {
		downloadProgress.removeFromSuperview()
		let main = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
		main.viewControllers?[2].tabBarItem.badgeValue = "new"
		presentConfirmation(image: UIImage(named: "downloadAction")!, message: "Episode Downloaded")
	}

	fileprivate func setupTable() {
		// setup the table view footer
		let footer = UIView()
		self.tableView.tableFooterView = footer
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}

	// MARK: - UITableViewDataSource

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return playerItems.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
		cell.playerItem = playerItems[indexPath.row]
		return cell
	}

	// MARK: - UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// safety check
		guard let podcast = self.podcast, (indexPath.row < playerItems.count) else {
			return
		}

		// start playing the selected item
		Player.shared.playList = playerItems
		Player.shared.currentPlaylistIndex = indexPath.row
		Player.shared.setPlayerItem(playerItems[indexPath.row])
		Player.shared.maximizePlayer()
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		// safety check
		guard let podcast = self.podcast, (indexPath.row < playerItems.count) else {
			return nil
		}

		// get the player item
		let playerItem = playerItems[indexPath.row]

		downloadProgress = LoadingView()

		if DownloadCache.shared.isUserDownloaded(playerItem: playerItem) {
			let downloadAction =
			UITableViewRowAction(style: .normal, title: "Download") {
				(_,_) in
				// Do Nothing Already Downloaded
			}
			return [downloadAction]
		}
		let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { [unowned self] (_, _) in
			UIApplication.shared.addSubview(view: self.downloadProgress)
			DownloadCache.shared.download(playerItem: playerItem, progress: {
				(completed) in
				self.downloadProgress.setPercentage(value: completed * 100)
			}, completion: {
				[weak self] (episode, error) in

				if (error == nil) {
					self?.addedToDownloads()
				} else {
					self?.showError(message: .downloadFailed)
				}
			})
		}
		downloadAction.backgroundColor = UIColor(named: "optionGreen")
		return [downloadAction]
	}

}
