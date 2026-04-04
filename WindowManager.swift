// © 2026 Stuart Thomas (stuart.thomas@mac.com)
// Licensed under MIT License
// Copyright, Designs and Patents Act 1988

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
