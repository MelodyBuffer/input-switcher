import Cocoa
import Carbon

if CommandLine.arguments.contains("--version") {
    print("input-switcher v1.0.0")
    exit(0)
}

class InputSwitcher {
    var appStates: [String: String] = [:]
    let stateFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/input-switcher/state.json")
    
    init() {
        createConfigDir()
        loadState()
        observeAppSwitch()
        observeInputChange()
    }
    
    func createConfigDir() {
        try? FileManager.default.createDirectory(
            at: stateFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    func observeAppSwitch() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let bundleId = app.bundleIdentifier else { return }
            
            if let savedInput = self.appStates[bundleId] {
                self.switchInput(to: savedInput)
            }
        }
    }
    
    func observeInputChange() {
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("AppleSelectedInputSourcesChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self,
                  let app = NSWorkspace.shared.frontmostApplication,
                  let bundleId = app.bundleIdentifier else { return }
            
            let currentInput = self.getCurrentInput()
            self.appStates[bundleId] = currentInput
            self.saveState()
        }
    }
    
    func getCurrentInput() -> String {
        let input = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let ptr = TISGetInputSourceProperty(input, kTISPropertyInputSourceID)
        return Unmanaged<CFString>.fromOpaque(ptr!).takeUnretainedValue() as String
    }
    
    func switchInput(to inputSource: String) {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else { return }
        
        for source in list {
            if let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
                let id = Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
                if id == inputSource {
                    TISSelectInputSource(source)
                    break
                }
            }
        }
    }
    
    func loadState() {
        guard let data = try? Data(contentsOf: stateFile),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }
        appStates = json
    }
    
    func saveState() {
        guard let data = try? JSONSerialization.data(withJSONObject: appStates) else { return }
        try? data.write(to: stateFile)
    }
}

let switcher = InputSwitcher()
print("Input Switcher started. Press Ctrl+C to stop.")
RunLoop.main.run()

//# Compile
//swiftc -O input-switcher.swift -o input-switcher
//
//# Run
//./input-switcher

