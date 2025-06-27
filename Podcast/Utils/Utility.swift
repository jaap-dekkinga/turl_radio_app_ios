//
//  Utility.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

func getString(text: String, font: CGFloat, weight: UIFont.Weight, color: UIColor) -> NSAttributedString {
	return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: font, weight: weight), NSAttributedString.Key.foregroundColor: color])
}
