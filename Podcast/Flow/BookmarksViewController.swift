//
//  BookmarksViewController.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/17/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class BookmarksViewController: BaseTableViewController {

	// MARK: - UIViewController

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		NotificationCenter.default.addObserver(forName: Bookmarks.changedNotification, object: nil, queue: nil) { notification in
			self.tableView.reloadData()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as! BookmarkCell
		if (indexPath.row < Bookmarks.shared.bookmarks.count) {
			let bookmark = Bookmarks.shared.bookmarks[indexPath.row]
			cell.setBookmark(bookmark)
		} else {
			cell.setBookmark(nil)
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Bookmarks.shared.bookmarks.count
	}

	// MARK: - UITableViewDelegate

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// setup the delete action
		let deleteAction = UIContextualAction(style: .destructive, title: nil) {
			action, sourceView, completionHandler in
			// delete the bookmark
			Bookmarks.shared.removeBookmark(at: indexPath.row)
//			self.tableView.deleteRows(at: [indexPath], with: .left)
			completionHandler(true)
		}
		deleteAction.backgroundColor = .systemRed
		deleteAction.image = UIImage(systemName: "trash")

		// set the swipe actions
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}

}
