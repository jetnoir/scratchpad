# Scratchpad for macOS — Developer Manual

**Version 1.0 — April 2026**

**Stuart Thomas** · Whitby, North Yorkshire · stuart.thomas@mac.com · [stuart-thomas.com](https://stuart-thomas.com)

*Copyright © 2026 Stuart Thomas. All rights reserved. CDPA 1988. AGPL v3.*

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Source Files](#3-source-files)
4. [How It Works](#4-how-it-works)
5. [Building](#5-building)
6. [Distribution](#6-distribution)
7. [API Reference](#7-api-reference)
8. [Design Decisions](#8-design-decisions)
9. [Contributing](#9-contributing)
10. [Licence](#10-licence)

---

## 1. Overview

Scratchpad is a menu-bar macOS app that provides a persistent, always-available text buffer accessible via `CMD+SHIFT+X`. It runs as an accessory app (no dock icon), floats above other windows, and stores text locally in `~/Library/Application Support/Scratchpad/scratchpad.txt`.

### Design Principles

- **Zero friction** — One keystroke to open, Escape to close
- **Local first** — No cloud, no network, no accounts
- **Plain text only** — All paste formatting is stripped (like Notepad)
- **Minimal** — 391 lines of Swift, zero dependencies
- **Trustworthy** — No analytics, no tracking, no hidden features

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────┐
│  main.swift                                             │
│  Entry point: creates NSApplication as .accessory       │
├─────────────────────────────────────────────────────────┤
│  AppDelegate.swift (208 lines)                          │
│  • Menu bar status item (note.text icon)                │
│  • NSWindow setup (floating, all spaces)                │
│  • Left-click toggle, right-click context menu          │
│  • Escape key handler (hides window)                    │
│  • CMD+Q handler (quits)                                │
│  • Standard Edit menu (Undo/Redo/Cut/Copy/Paste/All)    │
│  • About and Help dialogs                               │
├─────────────────────────────────────────────────────────┤
│  HotkeyManager.swift (41 lines)                         │
│  • Registers CMD+SHIFT+X via Carbon Event API           │
│  • Calls back to AppDelegate.toggleWindow()             │
├─────────────────────────────────────────────────────────┤
│  PlainTextView.swift (67 lines)                         │
│  • NSViewRepresentable wrapping NSTextView               │
│  • isRichText = false (strips all formatting on paste)  │
│  • Monospaced system font, 15pt                         │
│  • Disables smart quotes, dashes, autocorrect           │
│  • Two-way binding to StorageManager                    │
├─────────────────────────────────────────────────────────┤
│  StorageManager.swift (43 lines)                        │
│  • Reads/writes ~/Library/Application Support/          │
│    Scratchpad/scratchpad.txt                             │
│  • Background queue for saves (zero typing latency)     │
│  • Atomic writes for crash safety                       │
├─────────────────────────────────────────────────────────┤
│  WindowManager.swift (22 lines)                         │
│  • Saves/restores window frame via UserDefaults         │
│  • Falls back to center on first launch                 │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User types → NSTextView → Coordinator.textDidChange()
  → parent.text = textView.string
  → AppDelegate.scratchpadText setter
  → StorageManager.saveText() [background queue]
  → atomic write to scratchpad.txt

User reopens → AppDelegate.scratchpadText getter
  → StorageManager.readText()
  → String(contentsOf: url)
  → NSTextView.string = text
```

---

## 3. Source Files

| File | Lines | Purpose |
|------|-------|---------|
| `main.swift` | 10 | App entry point. Creates NSApplication as accessory. |
| `AppDelegate.swift` | 208 | Core app logic: menu bar, window, keyboard, menus. |
| `HotkeyManager.swift` | 41 | Global hotkey registration via Carbon `RegisterEventHotKey`. |
| `PlainTextView.swift` | 67 | SwiftUI ↔ AppKit bridge. NSTextView with plain text enforcement. |
| `StorageManager.swift` | 43 | File I/O with background saves and atomic writes. |
| `WindowManager.swift` | 22 | Window frame persistence via UserDefaults. |
| **Total** | **391** | |

---

## 4. How It Works

### 4.1 App Lifecycle

1. `main.swift` sets `NSApp.setActivationPolicy(.accessory)` — no dock icon
2. `AppDelegate.applicationDidFinishLaunching()`:
   - Creates menu bar status item with `note.text` SF Symbol
   - Creates floating NSWindow (`.floating` level, `.canJoinAllSpaces`)
   - Registers `CMD+SHIFT+X` hotkey via Carbon API
   - Installs local key monitor for Escape (hide) and CMD+Q (quit)
   - Injects standard Edit menu (Undo/Redo/Cut/Copy/Paste/Select All)

### 4.2 Hotkey System

The global hotkey uses the Carbon Event API (`RegisterEventHotKey`) because:
- `NSEvent.addGlobalMonitorForEvents` cannot intercept key events when another app is focused in the way needed
- Carbon hotkeys work system-wide regardless of focus
- The hotkey ID is `0x53435250` ("SCRP")
- Key code `0x07` = X, modifiers = `shiftKey | cmdKey`

### 4.3 Plain Text Enforcement

`PlainTextView` wraps `NSTextView` with:
```swift
textView.isRichText = false        // No RTF
textView.importsGraphics = false   // No images
textView.isAutomaticQuoteSubstitutionEnabled = false
textView.isAutomaticDashSubstitutionEnabled = false
textView.isAutomaticTextReplacementEnabled = false
textView.isAutomaticSpellingCorrectionEnabled = false
```

Any rich text pasted is automatically converted to plain text by AppKit when `isRichText = false`.

### 4.4 Storage

- Location: `~/Library/Application Support/Scratchpad/scratchpad.txt`
- Format: UTF-8 plain text
- Writes: atomic (`String.write(to:atomically:true)`)
- Thread: background `DispatchQueue` (`.background` QoS)
- Reads: synchronous on main thread (file is typically tiny)

### 4.5 Window Management

- Level: `.floating` (above all normal windows)
- Collection: `.canJoinAllSpaces` + `.fullScreenAuxiliary`
- Close button: intercepted → hides window instead of destroying
- Frame: saved to `UserDefaults` on move/resize, restored on launch

---

## 5. Building

### From Xcode

1. Open `Scratchpad.xcodeproj`
2. Select "My Mac" as destination
3. Build & Run (CMD+R)

### From Command Line

```bash
./build.sh
```

Or manually:
```bash
swiftc -O -o Scratchpad \
  main.swift AppDelegate.swift HotkeyManager.swift \
  PlainTextView.swift StorageManager.swift WindowManager.swift \
  -framework Cocoa -framework Carbon -framework SwiftUI
```

### Using XcodeGen

```bash
xcodegen generate  # Uses project.yml
open Scratchpad.xcodeproj
```

---

## 6. Distribution

### DMG Creation

The v1.0 DMG is hosted at `stuart-thomas.com/downloads/Scratchpad-1.0.dmg` (3.6 MB).

### Homebrew

```bash
brew install stuartthomas/scratchpad/scratchpad
```

### Code Signing

The app is currently unsigned. Users must:
1. Right-click DMG → Open (bypasses Gatekeeper first time)
2. Or: `xattr -d com.apple.quarantine Scratchpad-1.0.dmg`
3. Or: System Settings → Privacy & Security → Open Anyway

For future releases, consider an Apple Developer ID ($99/year) for notarisation.

---

## 7. API Reference

### AppDelegate

| Property/Method | Description |
|-----------------|-------------|
| `scratchpadText` | Computed property bridging to `StorageManager` |
| `setupMenuBar()` | Creates status bar item with SF Symbol icon |
| `setupWindow()` | Creates floating NSWindow with PlainTextView |
| `toggleWindow()` | Show/hide toggle (called by hotkey and menu bar click) |
| `showWindow()` | Activates app + makes window key |
| `hideWindow()` | Orders out window + hides app |
| `setupStandardEditMenu()` | Injects Undo/Redo/Cut/Copy/Paste/Select All |

### HotkeyManager

| Property/Method | Description |
|-----------------|-------------|
| `shared` | Singleton instance |
| `registerHotkey(action:)` | Registers CMD+SHIFT+X via Carbon API |
| `onHotkeyPressed` | Closure called when hotkey fires |

### PlainTextView

| Property/Method | Description |
|-----------------|-------------|
| `text: Binding<String>` | Two-way binding to text content |
| `makeNSView(context:)` | Creates NSTextView with plain text enforcement |
| `Coordinator` | NSTextViewDelegate that syncs changes to binding |

### StorageManager

| Property/Method | Description |
|-----------------|-------------|
| `shared` | Singleton instance |
| `readText()` | Returns contents of scratchpad.txt (empty string if missing) |
| `saveText(_:)` | Atomic write on background queue |

### WindowManager

| Property/Method | Description |
|-----------------|-------------|
| `shared` | Singleton instance |
| `saveWindowFrame(window:)` | Persists frame to UserDefaults |
| `restoreOrCenterWindow(window:)` | Restores saved frame or centres |

---

## 8. Design Decisions

### Why Carbon for Hotkeys?
`NSEvent.addGlobalMonitorForEvents` only *monitors* events — it can't prevent them from reaching other apps or reliably activate a background accessory app. Carbon's `RegisterEventHotKey` is the only reliable way to intercept a system-wide shortcut and bring a non-dock app to the foreground.

### Why NSTextView not TextEditor?
SwiftUI's `TextEditor` doesn't expose `isRichText` or formatting controls. By bridging to `NSTextView` via `NSViewRepresentable`, we get full control over paste behaviour, font, and smart features.

### Why Accessory App?
Setting `NSApp.setActivationPolicy(.accessory)` removes the dock icon and app-switcher entry. Scratchpad should be invisible until summoned — it's a tool, not an app you "use."

### Why Atomic Writes?
`String.write(to:atomically:true)` writes to a temp file first, then renames. If the app crashes mid-save, the previous version of the file survives. This prevents data loss at near-zero cost.

### Why Background Queue for Saves?
Every keystroke triggers `textDidChange`, which calls `saveText()`. Writing to disk on the main thread would add latency to typing. The background queue ensures the UI never blocks on I/O, even for large texts.

---

## 9. Contributing

Issues and pull requests welcome at [github.com/jetnoir/scratchpad](https://github.com/jetnoir/scratchpad).

By submitting a pull request, you agree to licence your contribution under AGPL v3 and assign copyright to Stuart Thomas (required for dual-licensing).

---

## 10. Licence

**AGPL v3** — Free for open-source use. [Commercial licence](mailto:stuart.thomas@mac.com) for proprietary use.

Governed by the laws of **England and Wales**. Full CDPA 1988 protections apply.

See [LICENSE](../LICENSE) for complete terms.

---

**github.com/jetnoir/scratchpad**

*Copyright © 2026 Stuart Thomas. All rights reserved.*
*Protected under the Copyright, Designs and Patents Act 1988 (CDPA).*
*Moral rights asserted under sections 77, 80, and 84.*
