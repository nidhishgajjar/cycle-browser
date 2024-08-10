//
//  scigicApp.swift
//  scigic
//
//  Created by Nidhish Gajjar on 2023-07-18.
//
import SwiftUI
import Sparkle

@main
struct ScigicApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Add updater manager
    @ObservedObject private var updaterManager = UpdaterManager()
    
    
    init() {
        
        // Create a strong reference to updaterManager
        let updater = self.updaterManager
        
        // Offload potentially long-running tasks to a background thread
        DispatchQueue.global(qos: .background).async {
            updater.startUpdater()
        }
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
