# Scratchpad

A hyperlocal clipboard for macOS. Press `CMD+SHIFT+X` and move text between screens instantly.

**No cloud. No accounts. No tracking.**

![Scratchpad](https://stuart-thomas.com/Scratchpad-icon.png)

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
- **Persistent but simple** — Stays until you clear it. Doesn't judge, log, or remember what you copy.
- **For everyone** — You're a developer switching between terminals and docs. You're a writer drafting across emails and files. You're anyone who pastes things.

## Why I built this

I spend my days designing systems that protect data and verify provenance. Scratchpad is the opposite—deliberately small, deliberately simple, deliberately yours.

### Values

**Independence** — No investors. No shareholders. No extraction. Just a tool that solves a problem.

**Honesty** — It does what it says. It doesn't do what it doesn't say. No hidden features, no dark patterns.

**Accessibility** — Built by a neurodivergent engineer. Designed to work. No friction. No surprises.

**Trust** — Your clipboard stays yours. No analytics. No tracking. No one watches what you paste.

## License

MIT License. You own the code. You can fork it, modify it, redistribute it.

See [LICENSE](LICENSE) for details.

## About

Built by **Stuart Thomas**, cryptographer. 40 years in computing. Designed the cryptographic systems protecting 60 million NHS patient records and 8 million daily contactless journeys across London.

- Website: [stuart-thomas.com](https://stuart-thomas.com)
- Other work: [Whitby Jet Provenance Platform](https://authenticwhitbyjet.co.uk)

## Support

Scratchpad is free. If it saves you time, consider a donation:

**[Support Scratchpad](https://monzo.me/stuartpaulthomas?h=od2RFz)**

## System requirements

- macOS 11+
- Intel or Apple Silicon

## Troubleshooting

**DMG won't open?**
- Right-click the DMG and select "Open"
- Or: `xattr -d com.apple.quarantine Scratchpad-1.0.dmg`

**App won't launch after drag-to-Applications?**
- Open System Settings → Privacy & Security
- Scroll to "Security"
- Click "Open Anyway" next to Scratchpad
- (This is standard for unsigned apps)

**Keyboard shortcut not working?**
- Check System Settings → Keyboard → Keyboard Shortcuts
- Ensure no other app is using `CMD+SHIFT+X`
- Try relaunching Scratchpad

## Contributing

Found a bug? Have a suggestion? Issues and pull requests welcome.

## Changelog

### v1.0 (March 2026)
- Initial release
- Keyboard shortcut: `CMD+SHIFT+X`
- Local persistent storage
- Clean, minimal interface

---

**Built with Swift. Licensed under MIT. No extraction. Just craft.**
