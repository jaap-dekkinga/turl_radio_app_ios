//
//  AudioProcessorUtils.swift
//  radio_app
//
//  Created by Anthony on 26/06/2025.
//  Copyright © 2025 TuneURL Inc. All rights reserved.
//

import Foundation
import AVFAudio

class AudioProcessorUtils {
    
    static func isSilent(_ buffer: AVAudioPCMBuffer, silenceThreshold: Float = 0.0001) -> Bool {
        let format = buffer.format
        
        switch format.commonFormat {
        case .pcmFormatFloat32:
            guard let channelData = buffer.floatChannelData else { return true }
            let channelCount = Int(format.channelCount)
            let frameLength = Int(buffer.frameLength)
            
            for channel in 0..<channelCount {
                let samples = channelData[channel]
                for frame in 0..<frameLength {
                    if abs(samples[frame]) > silenceThreshold {
                        return false
                    }
                }
            }
            
        case .pcmFormatInt16:
            guard let int16Data = buffer.int16ChannelData else { return true }
            let channelCount = Int(format.channelCount)
            let frameLength = Int(buffer.frameLength)
            
            // Normalize 16-bit to float in range [-1, 1]
            let normThreshold = Int16(silenceThreshold * Float(Int16.max))
            
            for channel in 0..<channelCount {
                let samples = int16Data[channel]
                for frame in 0..<frameLength {
                    if abs(samples[frame]) > normThreshold {
                        return false
                    }
                }
            }
            
        default:
            print("Unsupported audio format: \(format.commonFormat.rawValue)")
            return true
        }
        
        return true
    }
    
    static func framesToDuration(_ format: AVAudioFormat,  frames: AVAudioFrameCount) -> TimeInterval {
        let duration = Double(frames) / format.sampleRate
        return duration
    }
         
    static func makeSilentBuffer(_ format: AVAudioFormat, duration: TimeInterval) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(format.sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("v2 failed to allocate silent buffer")
            return nil
        }
        
        buffer.frameLength = frameCount
        
        if format.commonFormat == .pcmFormatFloat32 {
            let channels = Int(format.channelCount)
            for c in 0..<channels {
                memset(buffer.floatChannelData![c], 0, Int(frameCount) * MemoryLayout<Float>.size)
            }
        } else if format.commonFormat == .pcmFormatInt16 {
            let channels = Int(format.channelCount)
            for c in 0..<channels {
                memset(buffer.int16ChannelData![c], 0, Int(frameCount) * MemoryLayout<Int16>.size)
            }
        }
        
        return buffer
    }
    
}
