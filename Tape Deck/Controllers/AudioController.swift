//
//  AudioController.swift
//  Tape Deck
//
//  Created by Josh on 12/2/24.
//

import Foundation
import SwiftUI
import AVFoundation

class AudioController: NSObject, AVAudioPlayerDelegate {
    @ObservedObject static var appState = AppState.shared
    
    static var audioRecorder: AVAudioRecorder!
    static var audioPlayer: AVAudioPlayer!
    
    static func setupRecordingSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: FileController.tempFileURL(), settings: settings)
            audioRecorder.prepareToRecord()
            updateState(state: .ready)
        }
        catch {
            print("Setup for recording session failed.")
            print(error)
        }
    }
    
    static func startRecording() {
        guard appState.audioState == .ready else {
            return
        }
        
        audioRecorder.record()
        updateState(state: .recording)
        appState.didRecord = false
    }
    
    static func stopRecording() {
        audioRecorder?.stop()
        updateState(state: .ready)
        appState.didRecord = true
    }
    
    static func startPlaying(url: URL) {
        guard appState.audioState == .ready else {
            return
        }
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
            print(error)
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
            updateState(state: .playing)
        } catch {
            print("Playback failed.")
            print(error)
        }
    }
    
    static func stopPlaying() {
        audioPlayer?.stop()
        updateState(state: .ready)
    }
    
    static func reset() {
        stopPlaying()
        stopRecording()
        appState.didRecord = false
        appState.recordingIdentifier = nil
        updateState(state: .ready)
    }
    
    private static func updateState(state: AudioState) {
        appState.audioState = state
    }
}
