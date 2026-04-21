import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close any window SwiftUI Settings scene may restore
        DispatchQueue.main.async {
            NSApplication.shared.windows.forEach { $0.close() }
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "trash.fill", accessibilityDescription: "Clear Xcode DerivedData")
        button.action = #selector(clearDerivedData)
        button.target = self
    }

    @objc private func clearDerivedData() {
        let path = NSHomeDirectory() + "/Library/Developer/Xcode/DerivedData"
        let url = URL(fileURLWithPath: path)
        let fm = FileManager.default

        guard fm.fileExists(atPath: path) else {
            flashIcon(symbol: "checkmark.circle.fill")
            statusItem.button?.toolTip = "DerivedData already empty"
            return
        }

        let sizeKB = diskUsageKB(at: path)
        try? fm.removeItem(at: url)
        try? fm.createDirectory(at: url, withIntermediateDirectories: true)

        let sizeStr = formatSize(kb: sizeKB)
        flashIcon(symbol: "checkmark.circle.fill")
        statusItem.button?.toolTip = "Cleared: \(sizeStr)"
        sendNotification(title: "DerivedData Cleared", body: sizeStr)
    }

    private func flashIcon(symbol: String) {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            button.image = NSImage(systemSymbolName: "trash.fill", accessibilityDescription: "Clear Xcode DerivedData")
            self?.statusItem.button?.toolTip = nil
        }
    }

    private func diskUsageKB(at path: String) -> Int64 {
        let task = Process()
        let pipe = Pipe()
        task.launchPath = "/usr/bin/du"
        task.arguments = ["-sk", path]
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return Int64(output.components(separatedBy: "\t").first?.trimmingCharacters(in: .whitespaces) ?? "0") ?? 0
    }

    private func formatSize(kb: Int64) -> String {
        let mb = Double(kb) / 1024
        if mb >= 1024 { return String(format: "%.1f GB freed", mb / 1024) }
        return String(format: "%.0f MB freed", mb)
    }

    private func sendNotification(title: String, body: String) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            UNUserNotificationCenter.current().add(
                UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            )
        }
    }
}
