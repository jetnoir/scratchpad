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
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var window: NSWindow!
    
    // We bind our text state to StorageManager
    var scratchpadText: String {
        get { StorageManager.shared.readText() }
        set { StorageManager.shared.saveText(newValue) }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as a menu-bar only (accessory) application
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        setupWindow()
        
        // Register Cmd+Shift+X hotkey via Carbon
        HotkeyManager.shared.registerHotkey { [weak self] in
            DispatchQueue.main.async {
                self?.toggleWindow()
            }
        }
        
        // Listen locally for the Escape key to close the window, and Cmd+Q to quit
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Cmd+Q check (Command flag + 'q' keycode)
            if event.modifierFlags.contains(.command) && event.keyCode == 12 {
                NSApplication.shared.terminate(nil)
                return nil
            }
            
            // Escape key code is 53
            if event.keyCode == 53 {
                if let w = self?.window, w.isKeyWindow {
                    self?.hideWindow()
                    return nil // consume event
                }
            }
            return event
        }
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Scratchpad")
            button.action = #selector(statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        // Right click or Control click shows the standard menu
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            let menu = NSMenu()
            
            let toggleItem = NSMenuItem(title: "Toggle Scratchpad", action: #selector(toggleWindow), keyEquivalent: "X")
            toggleItem.keyEquivalentModifierMask = [.command, .shift]
            menu.addItem(toggleItem)
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Help", action: #selector(showHelp), keyEquivalent: "?"))
            menu.addItem(NSMenuItem(title: "About Scratchpad", action: #selector(showAbout), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Scratchpad", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            // Reset to nil so left click works as a toggle again
            statusItem.menu = nil
        } else {
            // Left click acts as a fast toggle
            toggleWindow()
        }
    }
    
    func setupWindow() {
        // Ensure standard text editing shortcuts are manually injected
        // because an accessory app does not get a default main menu easily.
        setupStandardEditMenu()
        
        // Create the core PlainTextView bridging to NSTextView
        let textBinding = Binding<String>(
            get: { self.scratchpadText },
            set: { self.scratchpadText = $0 }
        )
        let contentView = PlainTextView(text: textBinding)
        let hostingController = NSHostingController(rootView: contentView)
        
        // Initialize the NSWindow programmatically
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Scratchpad"
        window.level = .floating // Float above other applications
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = hostingController.view
        window.delegate = self
        window.isOpaque = true
        
        // Bring back bounds from last session or place in center
        WindowManager.shared.restoreOrCenterWindow(window: window)
    }
    
    private func setupStandardEditMenu() {
        let mainMenu = NSMenu()
        
        // Setup Quit menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit Scratchpad", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        
        // Setup Edit Menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        
        let undoItem = NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redoItem = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z") // Shift+Cmd+Z
        
        // Key standard cuts
        let cutItem = NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        let copyItem = NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        let pasteItem = NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        let selectAllItem = NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        editMenu.addItem(undoItem)
        editMenu.addItem(redoItem)
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(cutItem)
        editMenu.addItem(copyItem)
        editMenu.addItem(pasteItem)
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(selectAllItem)
        
        editMenuItem.submenu = editMenu
        NSApp.mainMenu = mainMenu
    }
    
    @objc func toggleWindow() {
        if window.isVisible && window.isKeyWindow {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    func showWindow() {
        // Bring to front, making key and active instantly
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    func hideWindow() {
        window.orderOut(nil)
        // Optionally deactivate app so previous app regains focus
        NSApp.hide(nil)
    }
    
    // Disable window closing fully killing the UI, just hide it
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        return false
    }
    
    func windowDidResize(_ notification: Notification) {
        WindowManager.shared.saveWindowFrame(window: window)
    }
    
    func windowDidMove(_ notification: Notification) {
        WindowManager.shared.saveWindowFrame(window: window)
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "About Scratchpad"
        alert.informativeText = "© 2026 Stuart Thomas (stuart.thomas@mac.com)
Licensed under MIT License
Copyright, Designs and Patents Act 1988"
        alert.alertStyle = .informational
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
    
    @objc func showHelp() {
        let alert = NSAlert()
        alert.messageText = "Scratchpad Help"
        alert.informativeText = "• Press ⇧⌘X from anywhere to quickly hide or show the scratchpad.
• Text pasted here is automatically saved and stripped of any formatting.
• Click the menu bar icon to toggle the window without the shortcut.
• Press Escape while editing to hide the window."
        alert.alertStyle = .informational
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
