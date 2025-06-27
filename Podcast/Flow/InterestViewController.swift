//
//  InterestViewController.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/28/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import TuneURL
import UIKit
import WebKit

class InterestViewController: UIViewController {

	// interface
	@IBOutlet weak var actionLabel: UILabel!
	@IBOutlet weak var webView: WKWebView!

	// public
	var userInteracted = false

	// private
	private var tuneURL: TuneURL.Match?

	// MARK: -

	class func create(with tuneURL: TuneURL.Match, wasUserInitiated: Bool) -> InterestViewController {
		let storyboard = UIStoryboard(name: "TuneURL", bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: "InterestViewController") as! InterestViewController
		viewController.tuneURL = tuneURL
		return viewController
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		webView.layer.cornerRadius = 16.0
		webView.layer.masksToBounds = true
		if let tuneURL = self.tuneURL {
			setupTuneURL(tuneURL)
		}
	}

	// MARK: - Actions

	@IBAction func close(_ sender: AnyObject?) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func openWebsite(_ sender: AnyObject?) {
		performAction()
	}

	// MARK: - Private

	private func performAction() {
		// safety check
		guard let tuneURL = self.tuneURL else {
			return
		}

		switch (tuneURL.type) {

			case "coupon":
				// TODO: save the coupon
				break

			case "open_page":
				// open web page
				if let itemURL = URL(string: tuneURL.info) {
					UIApplication.shared.open(itemURL, options: [:], completionHandler: nil)
				}

			case "phone":
				// TODO: open the phone number url
//				if let phoneURL = tuneURL.phoneURL {
//					UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
//				}
				break

			case "poll":
				// TODO: add polls
				break

			case "sms":
				// TODO: open message panel
				break

			case "save_page":
				// TODO: find out how this should work
				break

			default:
				break
		}

		// close
		self.dismiss(animated: true, completion: nil)
	}

	private func setupTuneURL(_ tuneURL: TuneURL.Match) {
		// setup the action message
		var actionMessage = ""

		switch (tuneURL.type) {
			case "coupon":
				actionMessage = "Tap to Save Coupon"
				webView.isHidden = true

			case "open_page":
				actionMessage = "Tap to Open"
				if let url = URL(string: tuneURL.info) {
					webView.load(URLRequest(url: url))
				}

			case "phone":
				actionMessage = "Tap to Call Now"
				webView.isHidden = true

			case "poll":
				webView.isHidden = true

			case "save_page":
				actionMessage = "Save bookmark for \(tuneURL.info)?"
				if let url = URL(string: tuneURL.info) {
					webView.load(URLRequest(url: url))
				}

			case "sms":
				actionMessage = "Tap to Message Now"
				webView.isHidden = true

			default:
				break
		}

		actionLabel.text = actionMessage
	}

}
