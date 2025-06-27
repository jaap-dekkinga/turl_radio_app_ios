//
//  MainViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

	// public
	let player = Player.shared

	// private
	private var playerCollapsedConstraint: NSLayoutConstraint!
	private var playerMaximizedConstraint: NSLayoutConstraint!
	private var playerMinimizedConstraint: NSLayoutConstraint!

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPlayer()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.shared.navigationController?.isNavigationBarHidden = true
    }

	// MARK: - Private

	fileprivate func setupPlayer() {
		guard let playerContainer = player.view else {
			return
		}

		player.delegate = self

		// setup the constraints on the player container
		playerContainer.translatesAutoresizingMaskIntoConstraints = false
		self.view.insertSubview(playerContainer, belowSubview: self.tabBar)
		playerContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		playerContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		playerContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

		// create the maximized player constraints
		playerMaximizedConstraint = playerContainer.topAnchor.constraint(equalTo: self.view.topAnchor)

		// create the minimized player constraints
		playerMinimizedConstraint = playerContainer.topAnchor.constraint(equalTo: self.tabBar.topAnchor, constant: -Player.miniPlayerHeight)

		// create the collapsed player constraints
		playerCollapsedConstraint = playerContainer.topAnchor.constraint(equalTo: self.tabBar.topAnchor, constant: -1)

		// initially collapsed
		playerCollapsedConstraint.isActive = true
	}

}

// MARK: - Player Delegate

extension MainViewController: PlayerDelegate {

	func playerMaximize() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			[unowned self] in

			player.hideMiniPlayer()
			playerCollapsedConstraint.isActive = false
			playerMaximizedConstraint.isActive = true
			playerMinimizedConstraint.isActive = false
			player.showFullPlayer()
			player.notifyContentInsetsShouldChange()

			self.tabBar.isHidden = true
		})
	}

	func playerMinimize() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			[unowned self] in

			player.hideFullPlayer()
			playerCollapsedConstraint.isActive = false
			playerMaximizedConstraint.isActive = false
			playerMinimizedConstraint.isActive = true
			player.showMiniPlayer(above: self.tabBar)
			player.notifyContentInsetsShouldChange()

			self.tabBar.isHidden = false
		})
	}

}
