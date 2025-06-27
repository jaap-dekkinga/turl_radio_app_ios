//
//  AVPlayerV2Delegate.swift
//  Podcast
//
//  Created by Anthony on 27/06/2025.
//  Copyright © 2025 TuneURL Inc. All rights reserved.
//


import AVFoundation
import Foundation
import TuneURL

protocol AVPlayerV2Delegate: NSObjectProtocol {
    func tuneAvailable(_ player: AVPlayerV2, matches: [TuneURL.Match])
}
