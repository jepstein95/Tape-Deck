//
//  RecorderButtonView.swift
//  Tape Deck
//
//  Created by Josh on 12/4/24.
//

import SwiftUI

struct RecorderButtonView: View {
    
    var image: String?
    var action: () -> Void
    var disabled: Bool
    var color: Color
    
    var body: some View {
        Button(action: action) {
            if let image = image {
                Image(systemName: image)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
            }
            else {
                Text("")
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .font(.headline)
        .tint(color)
        .disabled(disabled)
        .cornerRadius(5)
    }
}
