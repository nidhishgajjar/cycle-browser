
//  Created by Nidhish Gajjar on 2023-06-07.
//

import SwiftUI
import HotKey

struct SettingsView: View {
    @ObservedObject var hotKeyViewModel: ShortcutViewModel
//    @EnvironmentObject var authManager: AuthManager

    @State private var selectedKey: Key = .space
    @State private var isOptionModifierOn = true
    @State private var isCommandModifierOn = false
    @State private var isControlModifierOn = false
    @State private var isShiftModifierOn = false
    @State var email = ""
    @State private var showAlert = false
    @State private var hotKeyChangeAlert = false
    

    let availableKeys: [(Key, String)] = [
        (.j, "J"),
        (.k, "K"),
        (.l, "L"),
        (.o, "O"),
        (.space, "Space"),
        (.backslash, "Backslash"),
        // Add more keys if needed
    ]
    
    var atLeastOneModifierOn: Bool {
            isOptionModifierOn || isCommandModifierOn || isControlModifierOn || isShiftModifierOn
        }
    
    
    init(hotKeyViewModel: ShortcutViewModel) {
        self.hotKeyViewModel = hotKeyViewModel

        let keyString = UserDefaults.standard.string(forKey: "selectedKey") ?? "Space"
        if let key = availableKeys.first(where: { $0.1 == keyString })?.0 {
            _selectedKey = State(initialValue: key)
        } else {
            _selectedKey = State(initialValue: .space)
        }

        _isOptionModifierOn = State(initialValue: UserDefaults.standard.bool(forKey: "isOptionModifierOn"))
        _isCommandModifierOn = State(initialValue: UserDefaults.standard.bool(forKey: "isCommandModifierOn"))
        _isControlModifierOn = State(initialValue: UserDefaults.standard.bool(forKey: "isControlModifierOn"))
        _isShiftModifierOn = State(initialValue: UserDefaults.standard.bool(forKey: "isShiftModifierOn"))
    }

    
    func saveSettingsToUserDefaults() {
        if let keyString = availableKeys.first(where: { $0.0 == selectedKey })?.1 {
            UserDefaults.standard.setValue(keyString, forKey: "selectedKey")
        }
        UserDefaults.standard.setValue(isOptionModifierOn, forKey: "isOptionModifierOn")
        UserDefaults.standard.setValue(isCommandModifierOn, forKey: "isCommandModifierOn")
        UserDefaults.standard.setValue(isControlModifierOn, forKey: "isControlModifierOn")
        UserDefaults.standard.setValue(isShiftModifierOn, forKey: "isShiftModifierOn")
    }

    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .padding()

            TabView {
//                VStack {
//
//                    if !authManager.isUserLoggedIn || !authManager.isEmailVerified {
//
//                        NavigationLink("Log In", destination: LoginView())
//
//                    } else {
//                        Button("Log Out") {
//                            authManager.logoutUser()
//                        }
//
//                        Button("Send Password Rest Link") {
//                               authManager.resetPassword { success in
//                                   if success {
//                                       showAlert = true
//                                   }
//                               }
//                           }
//                        .alert(isPresented: $showAlert) {
//                                Alert(
//                                    title: Text("Password Reset Email Sent"),
//                                    message: Text("Please check your Inbox. Check your Junk folder before requesting another link"),
//                                    dismissButton: .default(Text("OK"))
//                                )
//                            }
//                    }
//                }
//                .tabItem {
//                    Text("Account")
//                }

                VStack {
                    Text("Change Shortcut").font(.headline).padding()
                    Text("Here you can customize your hotkey. Select the key and any modifiers you would like to use.")
                        .font(.subheadline)
                        .padding()
                    ScrollView {
                        Form {
                            Picker("Select Key", selection: $selectedKey) {
                                ForEach(availableKeys, id: \.0) { key, label in
                                    Text(label).tag(key)
                                }
                            }

                                

                            Toggle(isOn: $isOptionModifierOn) {
                                Text("Option Modifier")
                            }

                            Toggle(isOn: $isCommandModifierOn) {
                                Text("Command Modifier")
                            }

                            Toggle(isOn: $isControlModifierOn) {
                                Text("Control Modifier")
                            }

                            Toggle(isOn: $isShiftModifierOn) {
                                Text("Shift Modifier")
                            }
                        }
                        .padding()

                        Button("Change HotKey") {
                                  var modifiers: NSEvent.ModifierFlags = []

                                  if isOptionModifierOn {
                                      modifiers.insert(.option)
                                  }
                                  if isCommandModifierOn {
                                      modifiers.insert(.command)
                                  }
                                  if isControlModifierOn {
                                      modifiers.insert(.control)
                                  }
                                  if isShiftModifierOn {
                                      modifiers.insert(.shift)
                                  }

                                  let keyCombo = KeyCombo(key: selectedKey, modifiers: modifiers)
                                  hotKeyViewModel.changeHotKey(keyCombo: keyCombo)
                                  saveSettingsToUserDefaults()
                                  hotKeyChangeAlert = true  // Trigger alert for successful hotkey change
                              }
                              .disabled(!atLeastOneModifierOn) // Disable button if no modifier is on
                              .alert(isPresented: $hotKeyChangeAlert) {
                                  Alert(
                                      title: Text("Success"),
                                      message: Text("Hotkey was changed successfully."),
                                      dismissButton: .default(Text("OK"))
                                  )
                              }
                          }
                      }

                .tabItem {
                    Text("Shortcut")
                }
            }
        }
        .frame(width: 700, height: 600)
    }
}
