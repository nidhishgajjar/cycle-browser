//
//  AppDelegate.swift
//  scigic
//
//  Created by Nidhish Gajjar on 2023-07-18.
//

import SwiftUI
import HotKey
import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
//    var authManager: AuthManager!
    var mainWindow: NSWindow!
    var settingsWindow: NSWindow!
    var lastKnownPosition = [String: NSPoint]()
    var hotKeyViewModel: ShortcutViewModel!
    var commonContext: ContextViewModel!
    var tabManager: TabManagerViewModel
    var autoSuggestViewModel: AutoSuggestViewModel
    private var loginStatusCancellable: AnyCancellable?


    override init() {
//        authManager = AuthManager()
        commonContext = ContextViewModel()
        autoSuggestViewModel = AutoSuggestViewModel()
        
        self.tabManager = TabManagerViewModel(context: commonContext)
        
        
        
        
        super.init()
        hotKeyViewModel = ShortcutViewModel(toggleWindow: toggleMainWindow)
        

    }
    
    
    deinit {
        loginStatusCancellable?.cancel()
    }

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        


        mainWindow = MainWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
            styleMask: [.resizable, .borderless],
            backing: .buffered, defer: false)
        mainWindow.collectionBehavior.insert(.moveToActiveSpace)
        mainWindow.center()
        mainWindow.setFrameAutosaveName("Scigic")
        mainWindow.contentView = NSHostingView(rootView: ContentView().environmentObject(commonContext).environmentObject(tabManager).environmentObject(autoSuggestViewModel))
        mainWindow.backgroundColor = NSColor.clear

        mainWindow.orderOut(nil)

        settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings")
        settingsWindow.contentView = NSHostingView(rootView: SettingsView(hotKeyViewModel: hotKeyViewModel))
        settingsWindow.isReleasedWhenClosed = false   // Add this line
        settingsWindow.orderOut(nil)  // Initially, make the window not visible
        
        
        if !mainWindow.isVisible {
            // Show mainWindow
            toggleMainWindow()
        }
        
        

        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { (event) -> NSEvent? in
            if event.keyCode == 50 { // If Spacebar is pressed
                switch event.type {
                case .keyDown:
                    self.commonContext.isAskViewActive.toggle()
                    self.commonContext.askBarFocusedOnAGI.toggle()
                    self.commonContext.askTextFromPalette = ""
                    return nil
                default:
                    break
                }
                return nil
            }
            return event
        }
        

    }
    
    func toggleMainWindow() {
        if let mainWindow = self.mainWindow {
            NSApp.activate(ignoringOtherApps: true)
            

            let mouseLocation = NSEvent.mouseLocation
            let activeScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main!
            var windowFrame = mainWindow.frame

            // Check if window is on the active screen and is the key window
            if mainWindow.screen === activeScreen && mainWindow.isKeyWindow {
                // Store current position before hiding
                lastKnownPosition[activeScreen.localizedName] = mainWindow.frame.origin
                NSApp.hide(nil)
            } else {
                if let lastPosition = lastKnownPosition[activeScreen.localizedName] {
                    windowFrame.origin = lastPosition
                } else {
                    let targetScreenFrame = activeScreen.frame
                    windowFrame.origin.x = targetScreenFrame.origin.x + (targetScreenFrame.width - windowFrame.width) / 2
                    windowFrame.origin.y = targetScreenFrame.origin.y + (targetScreenFrame.height - windowFrame.height) / 2
                }
                mainWindow.setFrame(windowFrame, display: true)
                mainWindow.makeKeyAndOrderFront(nil)
            }
        }
    }



    



    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.orderOut(nil)
        }
    }



    func showSettingsWindow() {
        if !settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

}


//    func toggleMainWindow() {
//        if let mainWindow = self.mainWindow {
//            NSApp.activate(ignoringOtherApps: true)
//
//            let mouseLocation = NSEvent.mouseLocation
//            let activeScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main!
//            var windowFrame = mainWindow.frame
//
//            // Check if window is on the active screen and is the key window
//            if mainWindow.screen === activeScreen && mainWindow.isKeyWindow {
//                NSApp.hide(nil)
//            } else {
//                if let lastPosition = lastKnownPosition[activeScreen.localizedName] {
//                    windowFrame.origin = lastPosition
//                } else {
//                    let targetScreenFrame = activeScreen.frame
//                    windowFrame.origin.x = targetScreenFrame.origin.x + (targetScreenFrame.width - windowFrame.width) / 2
//                    windowFrame.origin.y = targetScreenFrame.origin.y + (targetScreenFrame.height - windowFrame.height) / 2
//                    lastKnownPosition[activeScreen.localizedName] = windowFrame.origin
//                }
//                mainWindow.setFrame(windowFrame, display: true)
//                mainWindow.makeKeyAndOrderFront(nil)
//            }
//        }
//    }



//
//func toggleMainWindow() {
//
//    if let mainWindow = self.mainWindow {
//        if mainWindow.isVisible {
//            print("is visible invoked")
//            if mainWindow.isKeyWindow {
//                print("is key window invoked")
//                lastKnownPosition[mainWindow.screen?.localizedName ?? ""] = mainWindow.frame.origin
//                NSApp.hide(nil)
//            } else {
//                print("is not key window invloked")
//                NSApp.activate(ignoringOtherApps: true)
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                    print("first dispatch")
//                    self.mainWindow.makeKeyAndOrderFront(nil)
////                    }
//            }
//        } else {
//            print("not visible invoked")
//            NSApp.activate(ignoringOtherApps: true)
//            let mouseLocation = NSEvent.mouseLocation
//            let activeScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main!
//            var windowFrame = mainWindow.frame
//            if let lastPosition = lastKnownPosition[activeScreen.localizedName] {
//                print("last position invoked")
//                windowFrame.origin = lastPosition
//            } else {
//                print("else block of last positon invoked")
//                let targetScreenFrame = activeScreen.frame
//                windowFrame.origin.x = targetScreenFrame.origin.x + (targetScreenFrame.width - windowFrame.width) / 2
//                windowFrame.origin.y = targetScreenFrame.origin.y + (targetScreenFrame.height - windowFrame.height) / 2
//                lastKnownPosition[activeScreen.localizedName] = windowFrame.origin
//            }
//            print("set frame about to be invoked")
//            mainWindow.setFrame(windowFrame, display: true)
////                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                print("invoke second dispatch")
//                            mainWindow.makeKeyAndOrderFront(nil)
////                }
//        }
//    }
//}






//extension Notification.Name {
//    static let enterKeyPressed = Notification.Name("enterKeyPressed")
//}




//        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
//           if event.keyCode == 49 {
//               // if space is pressed
//               if commonContext.isAskViewActive {
//                   // If the ask bar is active
//                   if commonContext.askText.isEmpty {
//                       // If the askText is empty, treat the space bar press as a command to hide the ask bar.
//                       commonContext.isAskViewActive = false
//                       return nil
//                   } else {
//                       // If askText is not empty, append a space to the askText.
//                       commonContext.askText.append(" ")
//                       return event
//                   }
//               } else {
//                   // If the ask bar is not active, treat the space bar press as a command to show the ask bar.
//                   commonContext.isAskViewActive = true
//                   return nil
//               }
//           } else if event.keyCode == 53 {
//               // If escape is pressed
//               if commonContext.isAskViewActive {
//                   // If the ask bar is active, treat the escape key press as a command to hide the ask bar.
//                   commonContext.isAskViewActive = false
//                   return nil
//               }
//           }
//           return event
//       }

//        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
//            if event.keyCode == 49 {
//                // if space is pressed
//                if commonContext.isAskViewActive {
//                    // If the ask bar is active
//                    if commonContext.askText.isEmpty {
//                        // If the askText is empty, treat the space bar press as a command to hide the ask bar.
//                        commonContext.isAskViewActive = false
//                        return nil
//                    } else {
//                        // If askText is not empty, append a space to the askText.
//                        commonContext.askText.append(" ")
//                        return event
//                    }
//                } else if !commonContext.isTyping {
//                    // If the ask bar is not active and the web view input field is not focused, treat the space bar press as a command to show the ask bar.
//                    commonContext.isAskViewActive = true
//                    return nil
//                }
//            } else if event.keyCode == 53 {
//                // If escape is pressed
//                if commonContext.isAskViewActive {
//                    // If the ask bar is active, treat the escape key press as a command to hide the ask bar.
//                    commonContext.isAskViewActive = false
//                    return nil
//                }
//            }
//            return event
//        }

//        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { (event) -> NSEvent? in
//            if event.keyCode == 49 {  // If space is pressed
//                switch event.type {
//                case .keyDown:
//                    var returnType: Bool?
//                    if self.spacebarDownTimestamp == nil {
//                        self.spacebarDownTimestamp = event.timestamp
//                        self.spacebarTimer = Timer.scheduledTimer(withTimeInterval: self.spacebarHoldDuration, repeats: false) { _ in
//                            returnType = false
//                        }
//                        returnType = true
//                    }
//
//                    if let returnType = returnType, returnType {
//                        return event
//                    } else {
//                        return nil
//                    }
//
//                case .keyUp:
//                    if let downTimestamp = self.spacebarDownTimestamp,
//                       event.timestamp - downTimestamp >= self.spacebarHoldDuration {
//                        // If the spacebar has been held down for at least 500ms
//                        if self.commonContext.isAskViewActive {
//                            self.commonContext.isAskViewActive = false
//                        } else {
//                            self.commonContext.isAskViewActive = true
//                        }
//                        self.spacebarDownTimestamp = nil
//                        return nil  // Consume the event without playing the sound
//                    }
//                    self.spacebarDownTimestamp = nil
//                    return event
//                default:
//                    return event
//                }
//            }
//            return event
//        }





//        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { (event) -> NSEvent? in
//            if event.keyCode == 49 {  // If space is pressed
//                switch event.type {
//                case .keyDown:
//                    var returnType: Bool?
//                    if self.spacebarDownTimestamp == nil {
//                        self.spacebarDownTimestamp = event.timestamp
//                        self.spacebarTimer = Timer.scheduledTimer(withTimeInterval: self.spacebarHoldDuration, repeats: false) { _ in
//                            returnType = false
//                            self.commonContext.isAskViewActive.toggle()
//                        }
//                        returnType = true
//                    }
//
//                    if let returnType = returnType, returnType {
//                        return event
//                    } else {
//                        return nil
//                    }
//
//                case .keyUp:
//                    // When the spacebar is released, invalidate the timer to prevent the view from switching
//                    self.spacebarTimer?.invalidate()
//                    self.spacebarTimer = nil
//                    self.spacebarDownTimestamp = nil
//
//                    return event
//                default:
//                    return event
//                }
//            }
//            return event
//        }
