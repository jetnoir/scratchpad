// © 2026 Stuart Thomas (stuart.thomas@mac.com)
// Licensed under MIT License
// Copyright, Designs and Patents Act 1988

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
