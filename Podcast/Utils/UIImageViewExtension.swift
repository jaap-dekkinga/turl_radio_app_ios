//
//  UIImageViewExtension.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit
import Alamofire

let imageCache = NSCache<AnyObject, UIImage>()

extension UIImageView {

	func downloadImage(url: String, completion: ((UIImage?) -> Void)? = nil) {
		// safety check
		guard (url.isEmpty == false) else {
			return
		}

		// look for the image in the image cache
		if let cachedImage = imageCache.object(forKey: url as AnyObject) {
			DispatchQueue.main.async { [weak self] in
				// show the image immediately
				self?.image = cachedImage
				completion?(cachedImage)
			}
			return
		}

		// download the image
		Alamofire.request(url).responseData { (response) in
			guard let data = response.value else {
				return
			}

			if let image = UIImage(data: data) {
				// save the image in the image cache
				imageCache.setObject(image, forKey: url as AnyObject)
				DispatchQueue.main.async { [weak self] in
					if let imageView = self {
						UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
							imageView.image = image
						}, completion: nil)
						completion?(image)
					}
				}
			}
		}
	}

}
