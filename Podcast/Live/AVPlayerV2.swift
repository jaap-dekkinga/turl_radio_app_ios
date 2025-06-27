//
//  AVPlayerClone.swift
//  Podcast
//
//  Created by Anthony on 24/06/2025.
//  Copyright © 2025 TuneURL Inc. All rights reserved.
//

import AVFoundation
import AVFAudio
import Foundation
import TuneURL
import AudioStreaming

class AVPlayerV2: NSObject {
    
    private let player = AudioPlayer()
    private let avPlayer = AVPlayer()
    
    private var processor: AudioProcessor?
    
    private var interval: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 600)
    
    private var timer: DispatchSourceTimer?
    private var timerCallback : ((CMTime) -> Void)?

    private var _rate: Float = 0
    
    private var playerItem: AVPlayerItemV2?
    private var loaded = false

    public weak var delegate: AVPlayerV2Delegate?
    
    var allowsExternalPlayback: Bool {
        get {
            return false
        }
        
        set {
        }
    }
    
    var timeControlStatus: AVPlayer.TimeControlStatus {
        switch player.state {
        case .playing:
            return AVPlayer.TimeControlStatus.playing
                    
        default:
            return AVPlayer.TimeControlStatus.paused
        }
    }
    
    @objc dynamic var currentItem: AVPlayerItemV2?

    @objc dynamic var rate: Float {
        get {
            return _rate
        }
        
        set {
            _rate = newValue
        }
    }
            
    @objc dynamic var volume: Float {
        get {
            return player.volume
        }
        
        set {
            player.volume = newValue
        }
    }
            
    override init() {
        super.init()

        processor = AudioProcessor(format: player.mainMixerNode.outputFormat(forBus: 0), delegate: self)
       
        setupFiltering()
        
        startTimer()
        
        player.delegate = self
    }
    
    deinit {
        stopTimer()
        timerCallback = nil
        
        processor?.cleanup()
        processor = nil
    }

    func currentTime() -> CMTime {
        let time = CMTimeMakeWithSeconds(player.progress, preferredTimescale: 600)
        return time
    }
    
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: dispatch_queue_t?, using block: @escaping @Sendable (CMTime) -> Void) {
        self.interval = interval
        
        timerCallback = block
    }
    
    func addTuneReadyDelegate(_ delegate: AVPlayerV2Delegate) {
        self.delegate = delegate
    }
    
    func seek(to time: CMTime) {
        if player.duration > 0 {
            player.seek(to: Double(time.seconds))
        }
    }
    
    func replaceCurrentItem(with item: AVPlayerItemV2?) {
        guard let urlAsset = item?.asset as? AVURLAsset else {
            stop()
            return
        }
        
        loaded = false
        playerItem = item

        playerItem?.duration = CMTime.indefinite
        playerItem?.status = .readyToPlay

        print("v2 replaceCurrentItem:", urlAsset.url)

        processor?.pause()
    }
        
    func playImmediately(atRate rate: Float) {
        player.rate = rate
        play()
    }
    
    func play() {
        if let urlAsset = playerItem?.asset as? AVURLAsset, !loaded {
            rate = 1

            player.play(url: urlAsset.url)
            loaded = true
        } else {
            rate = 1
            playerItem?.status = .readyToPlay
            player.resume()
        }
                
        //startTimer()
    }
    
    func pause() {
        if player.state == .playing {
            processor?.pause()
        }

        //stopTimer()
        
        rate = 0
        player.pause()
    }
    
    func stop() {
        processor?.pause()

        //stopTimer()
        
        rate = 0
        loaded = false
        player.stop()
    }
    
}

extension AVPlayerV2 {
    
    private func updateTimer() {
        let time = currentTime()

        currentItem?.duration = CMTimeMakeWithSeconds(player.duration, preferredTimescale: 600)

        //print("v2 updateTimer:", time.seconds)
        timerCallback?(time)
    }
    
    private func startTimer() {
        stopTimer()
        
        let seconds = interval.seconds
        print("v2 startTimer:", seconds)
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: seconds)
        timer?.setEventHandler { [weak self] in
            self?.updateTimer()
        }
        timer?.resume()
    }

    private func stopTimer() {
        timer?.cancel()
        //timer?.invalidate()
        timer = nil
    }
    
}

extension AVPlayerV2 {
    
    private func setupFiltering() {
        print("v2 setupFiltering:")
        
        let record = FilterEntry(name: "record") { [weak self] buffer, when in
            if self?.player.state != .playing {
                return
            }
            
            self?.processor?.enqueue(buffer)
        }
        
        player.frameFiltering.add(entry: record)
    }
    
}

extension AVPlayerV2: AudioPlayerDelegate {
    
    func audioPlayerDidStartPlaying(player: AudioStreaming.AudioPlayer, with entryId: AudioStreaming.AudioEntryId) {
        print("didStartPlaying")
        
        playerItem?.status = .readyToPlay
    }
    
    func audioPlayerDidFinishBuffering(player: AudioStreaming.AudioPlayer, with entryId: AudioStreaming.AudioEntryId) {
        print("didFinishBuffering")
        
    }
    
    func audioPlayerStateChanged(player: AudioStreaming.AudioPlayer, with newState: AudioStreaming.AudioPlayerState, previous: AudioStreaming.AudioPlayerState) {
        print("didFinishBuffering")
        
        if newState == .error {
            playerItem?.status = .failed
        } else {
            playerItem?.status = .readyToPlay
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AudioStreaming.AudioPlayer, entryId: AudioStreaming.AudioEntryId, stopReason: AudioStreaming.AudioPlayerStopReason, progress: Double, duration: Double) {
        print("didFinishPlaying")
        rate = 0
    }
    
    func audioPlayerUnexpectedError(player: AudioStreaming.AudioPlayer, error: AudioStreaming.AudioPlayerError) {
        print("unexpectedError")
        
        playerItem?.status = .failed
    }
    
    func audioPlayerDidCancel(player: AudioStreaming.AudioPlayer, queuedItems: [AudioStreaming.AudioEntryId]) {
        print("didCancel", queuedItems)
        
    }
    
    func audioPlayerDidReadMetadata(player: AudioStreaming.AudioPlayer, metadata: [String : String]) {
        print("didReadMetadata", metadata)
        
        
        if let streamTitle = metadata["StreamTitle"] {
            if let metadataOutput = playerItem?.metadataOutput {

                let startTime = CMTimeMakeWithSeconds(player.progress + 2, preferredTimescale: 600)
                let duration = CMTime(seconds: 10.0, preferredTimescale: 600)
                let timeRange = CMTimeRange(start: startTime, duration: duration)
                
                let metadataItem = AVMutableMetadataItem()
                metadataItem.identifier = .commonIdentifierTitle
                metadataItem.value = streamTitle as NSString
                metadataItem.dataType = "com.apple.metadata.datatype.UTF-8"
                metadataItem.extendedLanguageTag = "en"
                
                let timedMetadataGroup = AVTimedMetadataGroup(items: [metadataItem], timeRange: timeRange)
                
                var group = [AVTimedMetadataGroup]()
                group.append(timedMetadataGroup)
                
                if let queue = metadataOutput.delegateQueue {
                    queue.async() {
                        metadataOutput.delegate?.metadataOutput?(metadataOutput, didOutputTimedMetadataGroups: group, from: nil)
                    }
                } else {
                    metadataOutput.delegate?.metadataOutput?(metadataOutput, didOutputTimedMetadataGroups: group, from: nil)
                }
            }
        }
    }
        
}

extension AVPlayerV2: AudioProcessorDelegate {
    
    func tuneAvailable(_ matches: [TuneURL.Match]) {
        delegate?.tuneAvailable(self, matches: matches)
    }
    
}
