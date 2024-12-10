//
//  RecordingView.swift
//  Tape Deck
//
//  Created by Josh on 12/4/24.
//

import SwiftUI

struct RecordingView: View {
    
    var recording: Recording

    var body: some View {
        VStack {
            Text(recording.metadata.title)
                .font(.title)
                .padding(.bottom, 5)
            Text(recording.metadata.playAt.formatted(date: .abbreviated, time: .shortened))
            RecorderView(canRecord: false)
            Spacer()
            Text("Created on \(recording.createdAt.formatted(date: .numeric, time: .omitted))")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: FileController.recordingFileURL(identifier: recording.identifier)) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .padding()
        .padding()
    }
}
