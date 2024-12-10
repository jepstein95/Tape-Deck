//
//  AppState.swift
//  Tape Deck
//
//  Created by Josh on 12/6/24.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var areNotificationsAllowed: Bool? = nil
    @Published var isRecordingAllowed: Bool? = nil
    
    @Published var audioState: AudioState = .none
    @Published var didRecord: Bool = false
    @Published var recordingIdentifier: String? = nil
}
