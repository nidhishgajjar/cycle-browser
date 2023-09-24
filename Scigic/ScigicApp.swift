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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Add updater manager
    @ObservedObject private var updaterManager = UpdaterManager()
    
    init() {
        FirebaseApp.configure()
        
        updaterManager.startUpdater()
    }

    var body: some Scene {
        MenuBarExtra("", systemImage: "circle.dotted") {
            Button("Scigic") {
                appDelegate.toggleMainWindow()
            }
            Button("Settings") {
                appDelegate.showSettingsWindow()
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





