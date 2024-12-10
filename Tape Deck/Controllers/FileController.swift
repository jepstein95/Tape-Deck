//
//  FileController.swift
//  Tape Deck
//
//  Created by Josh on 12/2/24.
//

import AVFoundation
import SwiftUI

class FileController {
    @ObservedObject static var appState = AppState.shared
    
    static func saveRecording(title: String, playAt: Date) -> Bool {
        let fileManager = FileManager.default
        let tempFileURL = tempFileURL()
        
        if fileManager.fileExists(atPath: tempFileURL.path) {
            let identifier = Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")
            guard let folderURL = createFolder(identifier: identifier) else {
                return false
            }
            
            do {
                try fileManager.moveItem(at: tempFileURL, to: recordingFileURL(identifier: identifier))
            }
            catch {
                print("Could not copy temp file.")
                print(error)
                return false
            }
            
            do {
                let metadata = RecordingMetadata(title: title, playAt: playAt)
                let metadataUrl = metadataFileURL(identifier: identifier)
                let json = try JSONEncoder().encode(metadata)
                try json.write(to: metadataUrl)
                
                NotificationController.schedule(identifier: identifier, title: title, playAt: playAt)
                appState.didRecord = false
                
                return true
            }
            catch {
                print("Could not save metadata.")
                print(error)
                return false
            }
        }
        else {
            print("Could not get temp file.")
            return false
        }
    }
    
    static func deleteRecording(identifier: String) {
        let fileManager = FileManager.default
        
        let folderURL = recordingFolderURL(identifier: identifier)
        do {
            try fileManager.removeItem(at: folderURL)
        }
        catch {
            print("Could not delete recording.")
            print(error)
        }
    }
    
    static func loadRecording(identifier: String) -> Recording? {
        let fileManager = FileManager.default
        
        let recordingURL = recordingFileURL(identifier: identifier)
        if !fileManager.fileExists(atPath: recordingURL.path) {
            print("Could not get recording.")
            return nil
        }
        
        do {
            let json = try Data(contentsOf: metadataFileURL(identifier: identifier))
            let metadata = try JSONDecoder().decode(RecordingMetadata.self, from: json)
            return Recording(identifier: identifier, createdAt: creationDate(url: recordingURL), metadata: metadata)
        }
        catch {
            print("Could not get metadata.")
            return nil
        }
    }
    
    static func loadRecordings() -> [Recording] {
        var recordings = [Recording]()
        
        if let enumerator = FileManager.default.enumerator(at: recordingsFolderURL(), includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let url as URL in enumerator {
                do {
                    let fileAttributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                    if !fileAttributes.isRegularFile! {
                        let identifier = url.lastPathComponent
                        if let recording = loadRecording(identifier: identifier) {
                            recordings.append(recording)
                        }
                    }
                }
                catch {
                    print("Could not get recording. URL: \(url)")
                    print(error)
                }
            }
        }
        
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
        return recordings
    }
    
    static func documentPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func tempFileURL() -> URL {
        return documentPath().appendingPathComponent("Temp.m4a")
    }
    
    static func recordingsFolderURL() -> URL {
        return documentPath().appendingPathComponent("Recordings")
    }
    
    static func recordingFolderURL(identifier: String) -> URL {
        return recordingsFolderURL().appendingPathComponent(identifier)
    }
    
    static func recordingFileURL(identifier: String) -> URL {
        let folderURL = recordingFolderURL(identifier: identifier)
        return folderURL.appendingPathComponent("Recording.m4a")
    }
    
    static func metadataFileURL(identifier: String) -> URL {
        let folderURL = recordingFolderURL(identifier: identifier)
        return folderURL.appendingPathComponent("Metadata.json")
    }
    
    static func createFolder(identifier: String) -> URL? {
        var isDir: ObjCBool = true
        
        let folderURL = recordingsFolderURL().appendingPathComponent(identifier)
        
        if FileManager.default.fileExists(atPath: folderURL.path, isDirectory: &isDir) {
            print("Folder already exists.")
            return nil
        }
        
        do {
            try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            return folderURL
        } catch {
            print("Could not create folder.")
            print(error)
            return nil
        }
    }
    
    static func creationDate(url: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        }
        else {
            return Date()
        }
    }
}
