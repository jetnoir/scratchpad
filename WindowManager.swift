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


import Cocoa

class WindowManager {
    static let shared = WindowManager()
    private let frameKey = "SavedWindowFrame"
    
    func saveWindowFrame(window: NSWindow) {
        UserDefaults.standard.set(window.frameDescriptor, forKey: frameKey)
    }
    
    func restoreOrCenterWindow(window: NSWindow) {
        if let frameString = UserDefaults.standard.string(forKey: frameKey) {
            window.setFrame(from: frameString)
        } else {
            window.center()
        }
    }
}
