//
// Scratchpad for macOS
// Copyright (C) 2026 Stuart Thomas <stuart.thomas@mac.com>
// Whitby, North Yorkshire, England
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Free for open-source use under AGPL v3.
// Commercial licence: stuart.thomas@mac.com
//
// Moral rights asserted under ss.77 and 80 CDPA 1988.
// Governing law: England and Wales.
//


import Foundation
import Carbon

// Global C-compatible function for Carbon
fileprivate func carbonEventHandler(nextHandler: EventHandlerCallRef?, theEvent: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    HotkeyManager.shared.onHotkeyPressed?()
    return noErr
}

class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotKeyRef: EventHotKeyRef?
    var onHotkeyPressed: (() -> Void)?
    
    func registerHotkey(action: @escaping () -> Void) {
        self.onHotkeyPressed = action
        
        let hotKeyID = EventHotKeyID(signature: 0x53435250, id: 1) // "SCRP"
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        // Cmd + Shift + X 
        let keyCode = UInt32(0x07) // kVK_ANSI_X
        let modifiers = UInt32(shiftKey | cmdKey)
        
        InstallEventHandler(GetApplicationEventTarget(), carbonEventHandler, 1, &eventType, nil, nil)
        
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        print("Registered global hotkey Cmd+Shift+X")
    }
}
