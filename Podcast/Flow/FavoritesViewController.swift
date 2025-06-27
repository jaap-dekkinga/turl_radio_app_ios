//
//  FavoritesViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class FavoritesViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {

	fileprivate let cellId = "FavoritesCell"
	fileprivate let headerId = "FavoritesHeader"
	fileprivate let padding: CGFloat = 12.0
	fileprivate let spacing: CGFloat = 12.0

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// setup the collection view
		self.collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
		self.collectionView.register(EmptyFavorites.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteFavorite(_:)))
		gesture.minimumPressDuration = 0.6
		self.collectionView.addGestureRecognizer(gesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Radio", style: .plain, target: self, action: #selector(testTapped))
    }
        
    @objc func testTapped() {
        AppDelegate.shared.coordinator?.start()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.collectionView.reloadData()
		self.navigationController?.tabBarItem.badgeValue = nil
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "ShowEpisodesSegue"),
		   let episodesController = segue.destination as? EpisodesViewController,
		   let podcastCell = sender as? FavoriteCell {
			episodesController.podcast = podcastCell.podcast
		}
	}

	// MARK: - Actions

	@objc fileprivate func deleteFavorite(_ gesture: UILongPressGestureRecognizer) {
		let location = gesture.location(in: collectionView)
		if let index = collectionView.indexPathForItem(at: location) {
			let item = Favorites.shared.favorites[index.item]
			let confirmation = OptionSheet(title: "Remove from Favorites!", message: "Are you sure that you want to remove \"\(item.podcast.title)\" from your favorites library?")
			confirmation.addButton(image: UIImage(named: "delete")!, title: "Remove Podcast", color: UIColor(named: "optionRed")!) {
				[unowned self] in
				Favorites.shared.removeFavorite(at: index.item)
				self.collectionView.deleteItems(at: [index])
			}
			confirmation.show()
		}
	}

	// MARK: - UICollectionViewDataSource

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoriteCell
		cell.podcast = Favorites.shared.favorites[indexPath.row].podcast
		return cell
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Favorites.shared.favorites.count
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
		return view
	}

	// MARK: - UICollectionViewDelegateFlowLayout

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return spacing
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return spacing
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return (Favorites.shared.favorites.count == 0) ? CGSize(width: collectionView.frame.width, height: 400.0) : CGSize(width: 0, height: 0)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = ((view.frame.width - (2.0 * padding + spacing)) / 2.0)
		return CGSize(width: width, height: (width + 38.0))
	}

}
