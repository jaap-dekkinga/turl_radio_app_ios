//
//  DateExtension.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import Foundation

extension Date {
	func formatDate() -> String {
		let format = DateFormatter()
		format.dateFormat = "EEEE, MMM d, YYYY"
		let date = format.string(from: self)
		return date
	}
}
