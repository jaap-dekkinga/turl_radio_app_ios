//
//  AudioProcessor.swift
//  radio_app
//
//  Created by Anthony on 25/06/2025.
//  Copyright © 2025 TuneURL Inc. All rights reserved.
//

import Foundation
import AVFAudio
import TuneURL

protocol AudioProcessorDelegate: NSObjectProtocol {
    func tuneAvailable(_ matches: [TuneURL.Match])
}

final class AudioProcessor {
    
    private let syncQueue = DispatchQueue(label: "audio.processor", qos: .background)
    private let maxSegmentDuration: TimeInterval = 15
    private let minSegmentDuration: TimeInterval = 9
    
    private let silenceStartDuration: TimeInterval = 1
    private let silenceEndDuration: TimeInterval = 1
    
    private let format: AVAudioFormat
    private let settings: [String : Any]
    private let directory: URL
    
    private var tasks: [AVAudioPCMBuffer] = []
    private var outQueue: [AVAudioPCMBuffer] = []

    private var isRunning = false
    private var possibleTrigger = false

    private var speechActive = false

    private var frames: AVAudioFrameCount = 0
        
    private weak var delegate: AudioProcessorDelegate?

    init(format: AVAudioFormat, delegate: AudioProcessorDelegate?) {
        self.format = format
        self.directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.delegate = delegate
        
        self.settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount
        ] as [String : Any]
    }
    
    func cleanup() {
        delegate = nil
        isRunning = false
        tasks.removeAll()
        outQueue.removeAll()
    }
        
    func pause() {
        syncQueue.async {
            self.isRunning = false
            self.tasks.removeAll()
            self.outQueue.removeAll()
            self.speechActive = false
        }
    }
    
    func enqueue(_ buffer: AVAudioPCMBuffer) {
        syncQueue.async {
            self.tasks.append(buffer)
            if !self.isRunning {
                self.executeNext()
            }
        }
    }
    
}

extension AudioProcessor {
        
    private func executeNext() {
        guard !tasks.isEmpty else {
            isRunning = false
            return
        }
        
        isRunning = true
        let buffer = tasks.removeFirst()
        
        self.processBuffer(buffer)
            
        DispatchQueue.global().async {
            self.syncQueue.async {
                self.executeNext()
            }
        }
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        if !AudioProcessorUtils.isSilent(buffer) {
            if !speechActive {
                if !possibleTrigger {
                    print("v2 speech pre reset:")

                    resetBuffer()
                }
                
                print("v2 speech start:")
                speechActive = true
            }
            
            addBuffer(buffer)
            
            let bufferDuration = duration()
            
            if possibleTrigger {
                if bufferDuration > minSegmentDuration {
                    print("v2 speech mid commit:", bufferDuration)
                    commit()
                }
            } else if bufferDuration > maxSegmentDuration {
                print("v2 speech buffer overflow commit:", bufferDuration)
                
                commit()
            }
        } else {
            let bufferDuration = duration()

            if speechActive {
                speechActive = false
                print("v2 speech done:", bufferDuration)
                
                if bufferDuration > 1 && bufferDuration < 2 {
                    possibleTrigger = true

                    print("v2 silence after possible trigger", bufferDuration)
                } else if bufferDuration > maxSegmentDuration {
                    print("v2 silence after buffer overflow commit:", bufferDuration)
                    
                    commit()
                }
            }
        }
            
    }
    
    private func commit() {
        print("")
        print("v2 commit:")

        frames = 0

        let fileUrl = directory.appendingPathComponent("buffer.mp4")
        
        _ = autoreleasepool {
            flushBuffer(fileUrl)
        }
        
        possibleTrigger = false

        detectTune(fileUrl)
    }
            
}

extension AudioProcessor {
   
    func duration() -> TimeInterval {
        return AudioProcessorUtils.framesToDuration(format, frames: frames)
    }
    
    func resetBuffer() {
        frames = 0
        outQueue.removeAll()
    }
    
    func addBuffer(_ buffer: AVAudioPCMBuffer) {
        outQueue.append(buffer)
        
        frames += buffer.frameLength
    }
    
    private func flushBuffer(_ fileUrl: URL) -> Bool {
        try? FileManager.default.removeItem(at: fileUrl)

        guard let audioWriter = try? AVAudioFile(forWriting: fileUrl, settings: settings, commonFormat: format.commonFormat, interleaved: format.isInterleaved) else {
            print("v2 flush file err:")
            return false
        }
        
        //print("v2 flush:", fileUrl.path)
        
        if let silenceBuffer = AudioProcessorUtils.makeSilentBuffer(format, duration: silenceStartDuration) {
            try? audioWriter.write(from: silenceBuffer)
        }
                        
        outQueue.forEach { buffer in
            try? audioWriter.write(from: buffer)
        }
        
        outQueue.removeAll()
        
        if let silenceBuffer = AudioProcessorUtils.makeSilentBuffer(format, duration: silenceEndDuration) {
            try? audioWriter.write(from: silenceBuffer)
        }
        
        let len = UInt32(audioWriter.length)
        
        let duration = AudioProcessorUtils.framesToDuration(format, frames: len)
        print("v2 flush duration", duration, "frames: ", len)

        if #available(iOS 18.0, *) {
            // TODO audioWriter.close()
        }
        
        return true
    }
    
}

extension AudioProcessor {
 
    private func detectTune(_ fileURL: URL) {
        print("")
        print("v2 detectTune => size:", fileSize(fileURL))
        
        DispatchQueue.main.async {
            Detector.processAudio(for: fileURL) { [weak self] matches in
                print("v2 ***************")
                print("v2 detectTune matches:", matches.count)
                
                if matches.count > 0 {
                    DispatchQueue.main.async {
                        self?.delegate?.tuneAvailable([matches[0]])
                    }
                }
                
                self?.deleteFile(fileURL)
            }
        }
    }
    
}

extension AudioProcessor {
    
    private func fileSize(_ url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            print("v2 fileSize err: \(error)")
            return 0
        }
    }
    
    private func deleteFile(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
}
