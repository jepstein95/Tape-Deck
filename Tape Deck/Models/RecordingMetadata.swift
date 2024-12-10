//
//  RecordingMetadata.swift
//  Tape Deck
//
//  Created by Josh on 12/2/24.
//

import Foundation

struct RecordingMetadata: Encodable, Decodable {
    let title: String
    let playAt: Date
}
