//
//  NewRecordingView.swift
//  Tape Deck
//
//  Created by Josh on 12/2/24.
//

import SwiftUI

struct NewRecordingView: View {
    @ObservedObject var appState = AppState.shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var title = ""
    @State private var date = Date().addingTimeInterval(24 * 60 * 60)
    
    @State private var isSaved = false
    @State private var isShowingAlert = false
    @State private var error: String? = ""    
    
    var body: some View {
        VStack {
            Text("New Recording")
                .font(.title)
            RecorderView()
            Spacer()
            TextField(
                "Title",
                text: $title
            )
            .disableAutocorrection(true)
            DatePicker(selection: $date) {
                Text("Replay On")
            }
            Button(action: saveRecording) {
                Text("Save").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
            .disabled(!appState.didRecord)
        }
        .padding()
        .padding()
        .alert(isPresented: $isShowingAlert) {
            if isSaved {
                Alert(
                    title: Text("Success"),
                    message: Text("Your recording was saved!"),
                    dismissButton: .default(Text("OK")) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            else {
                Alert(
                    title: Text("Error"),
                    message: Text(error ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .gesture(DragGesture().onChanged { _ in
            hideKeyboard()
        })
    }
    
    private func saveRecording() {
        if title.isEmpty {
            error = "Please enter a title."
        }
        else if date < Date() {
            error = "Date must be in the future."
        }
        else {
            if FileController.saveRecording(title: title, playAt: date) {
                isSaved = true
            }
            else {
                error = "Could not save recording."
            }
        }
        isShowingAlert = true
    }
}

#Preview {
    NewRecordingView()
}
