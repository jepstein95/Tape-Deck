//
//  RecordingListView.swift
//  Tape Deck
//
//  Created by Josh on 12/2/24.
//

import SwiftUI

struct RecordingListView: View {
    @ObservedObject var appState = AppState.shared
    
    @State var recordings: [Recording] = [Recording]()
    @State var isRecording = false
    
    var body: some View {
        VStack {
            Text("Recordings")
                .font(.title)
                .padding(.top, 20)
            if recordings.isEmpty {
                Spacer()
                Text("No saved recordings.")
            }
            else {
                List {
                    ForEach(recordings, id: \.createdAt) { recording in
                        Button(action: {
                            appState.recordingIdentifier = recording.identifier
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(recording.metadata.title)
                                        .font(.title)
                                        .padding(.bottom, 5)
                                    Text(recording.createdAt.formatted(date: .numeric, time: .omitted))
                                        .font(.footnote)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(recording.metadata.playAt.formatted(date: .abbreviated, time: .omitted))
                                    Text(recording.metadata.playAt.formatted(date: .omitted, time: .shortened))
                                }
                                Image(systemName: "bell.fill")
                                    .padding(.leading, 10)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            Spacer()
            Button(action: { isRecording = true }) {
                Text("New").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
            .padding()
                
            if appState.recordingIdentifier != nil,
            let recording = recordings.first(where: { $0.identifier == appState.recordingIdentifier }) {
                NavigationLink(destination: RecordingView(recording: recording), isActive: .constant(true)) {
                    EmptyView()
                }
            }
            NavigationLink(destination: NewRecordingView(), isActive: $isRecording) {
                EmptyView()
            }
        }
        .onAppear() {
            recordings = FileController.loadRecordings()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach { i in
            let recording = recordings[i]
            FileController.deleteRecording(identifier: recording.identifier)
            NotificationController.cancel(identifier: recording.identifier)
        }
        recordings.remove(atOffsets: offsets)
    }
}
