# Scratchpad

A hyperlocal clipboard for macOS. Press `CMD+SHIFT+X` and move text between screens instantly.

**No cloud. No accounts. No tracking.**

## What it does

Your Mac's clipboard is half a tool. You paste something, close the app, and it's gone. Unsafe paste websites demand your trust. Loading an app takes forever when you just need to move five words.

**Scratchpad** is a one-keystroke scratchpad that lives on your Mac. Paste something, close it, grab it later. Your text stays local. It stays yours.

## Download

**[Download Scratchpad v1.0](https://stuart-thomas.com/downloads/Scratchpad-1.0.dmg)** (3.6 MB)

Or via Homebrew:
```bash
brew install stuartthomas/scratchpad/scratchpad
```

## How to use

1. **Launch** the app from Applications
2. **Press** `CMD+SHIFT+X` anywhere
3. **Your scratchpad appears**
4. **Paste, edit, copy, close**

That's it. No setup. No accounts. No friction.

## Features

- **Instant access** — `CMD+SHIFT+X`. Not in the dock. Not in Spotlight. Just there.
- **Local first** — Your text lives on your Mac. Not on a server. Not in someone else's database.
- **Persistent** — Stays until you clear it. Survives restarts.
- **Plain text only** — Strips all formatting on paste. Like Notepad, but better.
- **Floating window** — Always on top, visible across all spaces.
- **Menu bar app** — Lives in the menu bar. Left-click toggles, right-click for options.
- **Window memory** — Remembers size and position between sessions.

## Architecture

```
┌─────────────────────────────────┐
│  main.swift                     │  Entry point (accessory app)
├─────────────────────────────────┤
│  AppDelegate.swift              │  Menu bar, window, keyboard
├─────────────────────────────────┤
│  HotkeyManager.swift            │  CMD+SHIFT+X via Carbon API
│  PlainTextView.swift            │  NSTextView (strips formatting)
│  StorageManager.swift           │  ~/Library/Application Support/
│  WindowManager.swift            │  Frame persistence
└─────────────────────────────────┘
```

391 lines of Swift. Zero dependencies. Zero frameworks beyond AppKit.

## System requirements

- macOS 11+
- Intel or Apple Silicon

## Troubleshooting

**DMG won't open?**
```bash
xattr -d com.apple.quarantine Scratchpad-1.0.dmg
```

**App won't launch?**
Open System Settings → Privacy & Security → Click "Open Anyway"

**Keyboard shortcut not working?**
Check no other app uses `CMD+SHIFT+X`. Relaunch Scratchpad.

## Licence

**AGPL v3** — Free for open-source use. [Commercial licence](mailto:stuart.thomas@mac.com) available.

See [LICENSE](LICENSE) for full terms (including English law provisions and CDPA assertions).

## Author

**Stuart Thomas** — Whitby, North Yorkshire, England
- Web: [stuart-thomas.com](https://stuart-thomas.com)
- Email: stuart.thomas@mac.com
- NFC Platform: [authenticwhitbyjet.co.uk](https://authenticwhitbyjet.co.uk)

## Support

Scratchpad is free. If it saves you time:

**[Support Scratchpad](https://monzo.me/stuartpaulthomas?h=od2RFz)**

---

*Copyright © 2026 Stuart Thomas. All rights reserved.*
*Protected under the Copyright, Designs and Patents Act 1988 (CDPA).*
*Moral rights asserted under sections 77, 80, and 84.*
