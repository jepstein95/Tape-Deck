//
//  RecorderView.swift
//  Tape Deck
//
//  Created by Josh on 12/6/24.
//

import Foundation
import SwiftUI

struct RecorderView: View {
    @ObservedObject var appState = AppState.shared
    
    var canRecord = true
    
    var canStartPlaying: Bool {
        return appState.audioState == .ready && (appState.didRecord || appState.recordingIdentifier != nil)
    }
    
    var canStopPlaying: Bool {
        return appState.audioState == .playing
    }
    
    var canToggleRecording: Bool {
        if !canRecord {
            return false
        }
        return appState.audioState == .ready || appState.audioState == .recording
    }
    
    var body: some View {
        VStack {
            Divider()
            VStack(alignment: .trailing) {
                Spacer()
                Image("cassette")
                    .resizable()
                    .scaledToFit()
            }
            .frame(height: 250)
            HStack {
                RecorderButtonView(
                    image: appState.audioState == .recording ? "square.fill" : "circle.fill",
                    action: toggleRecording,
                    disabled: !canToggleRecording,
                    color: .red
                )
                RecorderButtonView(action: {}, disabled: true, color: .red)
                RecorderButtonView(action: {}, disabled: true, color: .red)
                RecorderButtonView(
                    image: "play.fill",
                    action: startPlaying,
                    disabled: !canStartPlaying,
                    color: .green
                )
                RecorderButtonView(
                    image: "stop.fill",
                    action: stopPlaying,
                    disabled: !canStopPlaying,
                    color: .red
                )
            }
            VStack {
                if appState.audioState == .recording {
                    HStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 25, height: 25)
                        Text("Recording")
                            .font(.system(size: 24))
                    }
                    .blinking(duration: 0.5)
                }
            }
            .frame(height: 50)
            Divider()
        }
        .onDisappear(perform: {
            AudioController.reset()
        })
    }
    
    private func startPlaying() {
        if appState.didRecord {
            AudioController.startPlaying(url: FileController.tempFileURL())
        }
        else if let identifier = appState.recordingIdentifier {
            let url = FileController.recordingFileURL(identifier: identifier)
            AudioController.startPlaying(url: url)
        }
    }
    
    private func stopPlaying() {
        AudioController.stopPlaying()
    }
    
    private func toggleRecording() {
        if appState.audioState == .recording {
            AudioController.stopRecording()
        }
        else {
            AudioController.startRecording()
        }
    }
}
