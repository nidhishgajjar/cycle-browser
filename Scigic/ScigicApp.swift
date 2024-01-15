//
//  scigicApp.swift
//  scigic
//
//  Created by Nidhish Gajjar on 2023-07-18.
//
import SwiftUI
import Firebase
import Sparkle

@main
struct ScigicApp: App {
    
    @EnvironmentObject var webSocketService: WebSocketService
    
    // Add updater manager
    @ObservedObject private var updaterManager = UpdaterManager()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        
        // Create a strong reference to updaterManager
        let updater = self.updaterManager
        
        // Offload potentially long-running tasks to a background thread
        DispatchQueue.global(qos: .background).async {
            FirebaseApp.configure()
            updater.startUpdater()
        }
    }

    var body: some Scene {
        MenuBarExtra("", systemImage: "circle.dotted") {
            Button("Scigic") {
                DispatchQueue.global(qos: .background).async {
                    appDelegate.toggleMainWindow()
                }
            }
            Button("Settings") {
                DispatchQueue.global(qos: .background).async {
                    appDelegate.showSettingsWindow()
                }
            }
            
            // Add CheckForUpdatesView
            CheckForUpdatesView(updater: updaterManager.updaterController.updater)

            Divider()
            Button("Disable") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
