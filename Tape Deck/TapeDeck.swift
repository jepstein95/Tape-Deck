//
//  TapeDeck.swift
//  Tape Deck
//
//  Created by Josh on 12/2/24.
//

import SwiftUI
import AVFoundation

@main
struct TapeDeck: App {
    @ObservedObject var appState = AppState.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if appState.areNotificationsAllowed == false {
                    Text("Notification permission denied.")
                }
                else if appState.isRecordingAllowed == false {
                    Text("Recording permimssion denied.")
                }
                else {
                    RecordingListView()
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @ObservedObject var appState = AppState.shared
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.appState.areNotificationsAllowed = granted
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            self.appState.isRecordingAllowed = granted
            AudioController.setupRecordingSession()
        }
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        appState.recordingIdentifier = response.notification.request.identifier
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge])
    }
}
