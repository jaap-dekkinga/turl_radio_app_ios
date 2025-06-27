//
//  DownloadsViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class DownloadsViewController: BaseTableViewController {

	fileprivate let cellId = "EpisodeCell"

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		// setup the table view footer
		let footer = UIView()
		self.tableView.tableFooterView = footer
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		self.navigationController?.tabBarItem.badgeValue = nil
	}

	// MARK: - UITableViewDataSource

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return DownloadCache.shared.userDownloads.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
		cell.playerItem = DownloadCache.shared.userDownloads[indexPath.row]
		return cell
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return TextTableViewHeader(text: "You have not downloaded any podcasts.")
	}

	// MARK: - UITableViewDelegate

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let playerItem = DownloadCache.shared.userDownloads[indexPath.row]
		let downloadAction = UITableViewRowAction(style: .normal, title: "Delete") {
			[unowned self] (_, index) in

			let confirmation = OptionSheet(title: "Remove from Downloads!", message: "Are you sure that you want to remove \"\(playerItem.displayTitle)\" from your downloads library. You will no longer have access to this podcast.")
			confirmation.addButton(image: UIImage(named: "delete")!, title: "Remove Episode", color: UIColor(named: "optionRed")!) {
				[unowned self] in
				DownloadCache.shared.removeDownload(for: playerItem)
				tableView.deleteRows(at: [index], with: .automatic)
				presentConfirmation(image: UIImage(named: "tick")!, message: "Episode Deleted")
			}
			confirmation.show()
		}
		downloadAction.backgroundColor = UIColor(named: "optionRed")
		return [downloadAction]
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return (DownloadCache.shared.userDownloads.count == 0) ? 250.0 : 0.0
	}

}
