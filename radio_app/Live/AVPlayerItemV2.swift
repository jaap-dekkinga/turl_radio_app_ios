//
//  AVPlayerItemV2.swift
//  radio_app
//
//  Created by Anthony on 27/06/2025.
//  Copyright © 2025 TuneURL Inc. All rights reserved.
//

import AVFoundation
import Foundation

class AVPlayerItemV2: NSObject {
    @objc dynamic var duration: CMTime = CMTime.indefinite
    @objc dynamic var status: AVPlayerItem.Status = .readyToPlay
    @objc dynamic var isPlaybackLikelyToKeepUp = true
    @objc dynamic var isPlaybackBufferEmpty = false
    
    var metadataOutput: AVPlayerItemMetadataOutput?

    let asset: AVAsset

    init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        self.asset = asset
    }
    
    func add(_ metadataOutput: AVPlayerItemMetadataOutput) {
        // TODO
        self.metadataOutput = metadataOutput
    }
    
    func remove(_ metadataOutput: AVPlayerItemMetadataOutput) {
        // TODO
        self.metadataOutput = nil
    }
    
}
