# input-switcher
Windows-like per-app input source for macOS. Remember your input method in each application. CLI-only.

## Why
On macOS, the input source is always global and doesn't remember your choice for each app. This is annoying if you use multiple languages. 

本项目解决 macOS 输入法状态全局、不随窗口切换记忆的问题，方便多语言用户。

For example:
- You want English in Terminal, but Chinese in WeChat
- Switching between apps means constantly toggling input methods
- This tool remembers your preference for each app automatically

## How it works
- Monitors app switching events (no polling, purely event-driven)
- Saves input source state per app in `~/.config/input-switcher/state.json`
- When you switch apps, automatically restores the last input method you used
- When you manually change input method, remembers it for the current app
- Runs as a background LaunchAgent service - no GUI, no menubar icon

## How to use

### Quick start (manual)
```bash
# Compile
swiftc -O input-switcher.swift -o input-switcher

# Move to bin
mkdir -p ~/.local/bin
mv input-switcher ~/.local/bin/

# Create LaunchAgent plist
cat > ~/Library/LaunchAgents/com.user.inputswitcher.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.inputswitcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/.local/bin/input-switcher</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/.config/input-switcher/error.log</string>
    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/.config/input-switcher/output.log</string>
</dict>
</plist>
EOF

# Load service
launchctl load ~/Library/LaunchAgents/com.user.inputswitcher.plist

# Grant Accessibility permission
# Go to: System Settings → Privacy & Security → Accessibility
# Add Terminal (or your terminal app)
```

### Check status
```bash
# Check if service is running
launchctl list | grep inputswitcher

# View logs
tail -f ~/.config/input-switcher/error.log

# View saved states
cat ~/.config/input-switcher/state.json
```

### Uninstall
```bash
launchctl unload ~/Library/LaunchAgents/com.user.inputswitcher.plist
rm ~/Library/LaunchAgents/com.user.inputswitcher.plist
rm ~/.local/bin/input-switcher
rm -rf ~/.config/input-switcher
```

## Requirements
- macOS 10.15+
- Xcode Command Line Tools (for compiling)
- Accessibility permission

## TODO
- [ ] One-line install script (`curl | bash`)
- [ ] Default input source setting (e.g., set English as default for new apps)
- [ ] Prebuilt binaries in GitHub Releases
- [ ] Homebrew formula

## License
MIT

## Similar projects
- [KeyboardHolder](https://github.com/leaves615/KeyboardHolder) - GUI version with menubar icon
- [Kawa](https://github.com/hatashiro/kawa) - Input source switcher with GUI

This project is inspired by these tools but focuses on being lightweight and CLI-only.