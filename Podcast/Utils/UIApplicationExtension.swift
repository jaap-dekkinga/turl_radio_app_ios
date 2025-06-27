//
//  UIApplicationExtension.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

extension UIApplication {

	func addSubview(view: UIView) {
		let main = keyWindow?.rootViewController
		main?.view.addSubview(view)
	}

}
