
//  Created by Nidhish Gajjar on 2023-06-07.
//

import SwiftUI
import Combine
import HotKey
import AppKit

class ShortcutViewModel: ObservableObject {
    @Published var hotKey: HotKey?
    var toggleWindow: (() -> Void)?

    init(toggleWindow: @escaping (() -> Void)) {
        self.toggleWindow = toggleWindow
        
        let loadedKeyCombo = loadHotKeyFromUserDefaults()
        hotKey = HotKey(keyCombo: loadedKeyCombo, keyDownHandler: { [weak self] in
            self?.toggleWindow?()
        }, keyUpHandler: nil)
    }

    func loadHotKeyFromUserDefaults() -> KeyCombo {
        let selectedKey = UserDefaults.standard.string(forKey: "selectedKey") ?? "Space"
        let key = Key(string: selectedKey) ?? .space
        var modifiers: NSEvent.ModifierFlags = []
        
        // Check if the keys exist in UserDefaults before trying to get their value
        if UserDefaults.standard.object(forKey: "isOptionModifierOn") != nil {
            if UserDefaults.standard.bool(forKey: "isOptionModifierOn") {
                modifiers.insert(.option)
            }
        } else {
            modifiers.insert(.option) // Set Option as default if no preference has been set
        }
        
        if UserDefaults.standard.bool(forKey: "isCommandModifierOn") {
            modifiers.insert(.command)
        }
        if UserDefaults.standard.bool(forKey: "isControlModifierOn") {
            modifiers.insert(.control)
        }
        if UserDefaults.standard.bool(forKey: "isShiftModifierOn") {
            modifiers.insert(.shift)
        }
        
        return KeyCombo(key: key, modifiers: modifiers)
    }


    func changeHotKey(keyCombo: KeyCombo) {
        hotKey = HotKey(keyCombo: keyCombo, keyDownHandler: { [weak self] in
            self?.toggleWindow?()
        }, keyUpHandler: nil)
    }

    @objc func hotKeyPressed() {
        toggleWindow?()
    }
}


