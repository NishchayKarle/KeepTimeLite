//
//  AppDelegate.swift
//  KeepTimeLite
//
//  Created by Nishchay Karle on 5/23/24.
//

import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate {
    var trackers: [TimerManager] = []
    var statusItems: [NSStatusItem] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Add initial timers
        addNewTimer(startTime: 3600, isCountingUp: false, label: "Count Down: ", symbolName: "arrow.down", textColor: NSColor.systemRed)
        addNewTimer(startTime: 0, isCountingUp: true, label: "Count Up: ", symbolName: "arrow.up", textColor: NSColor.systemGreen)
        
        for item in trackers {
            item.start()
        }
    }

    func addNewTimer(startTime: TimeInterval, isCountingUp: Bool, label: String, symbolName: String, textColor: NSColor) {
        let newItem = TimerManager(startTime: startTime, isCountingUp: isCountingUp)
        
        trackers.append(newItem)
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = createImageFromNumber(label: label, time: startTime, symbolName: symbolName, textColor: textColor)
            let customView = CustomStatusItemView(frame: button.bounds)
            customView.menuProvider = { [weak self, weak newItem] in
                self?.createMenu(for: newItem) ?? NSMenu()
            }
            button.addSubview(customView)
            button.action = #selector(statusItemClicked(_:))
            button.target = self
        }
        statusItems.append(statusItem)
    }

    func createMenu(for timerManager: TimerManager?) -> NSMenu {
        let menu = NSMenu()
        let pauseResumeItem = NSMenuItem(title: "Pause Timer", action: #selector(togglePauseMenuItem(_:)), keyEquivalent: "P")
        pauseResumeItem.tag = 1
        pauseResumeItem.representedObject = timerManager
        
        let resetItem = NSMenuItem(title: "Reset Timer", action: #selector(resetTimer(_:)), keyEquivalent: "R")
        resetItem.representedObject = timerManager

        menu.addItem(pauseResumeItem)
        menu.addItem(resetItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q"))
        
        return menu
    }

    func updateMenu(for timerManager: TimerManager) {
        guard let index = trackers.firstIndex(where: { $0 === timerManager }),
              let menu = statusItems[index].menu else { return }

        if let pauseResumeItem = menu.item(withTag: 1) {
            pauseResumeItem.title = timerManager.isPaused ? "Resume Timer" : "Pause Timer"
        }
    }

    @objc func statusItemClicked(_ sender: AnyObject) {
        if let button = sender as? NSStatusBarButton,
           let index = statusItems.firstIndex(where: { $0.button === button }),
           index < trackers.count {
            let tracker = trackers[index]
            tracker.pauseOrResume()
            button.image = createImageFromNumber(label: "one", time: tracker.remainingTime, symbolName: "arrow.up", textColor: NSColor.white)
        }
    }

    @objc func togglePauseMenuItem(_ sender: NSMenuItem) {
        guard let timerManager = sender.representedObject as? TimerManager else { return }
        togglePause(for: timerManager)
    }

    func togglePause(for timerManager: TimerManager) {
        if timerManager.isPaused {
            timerManager.start()
        } else {
            timerManager.stop()
        }
        updateMenu(for: timerManager)
    }

    @objc func resetTimer(_ sender: NSMenuItem) {
        guard let timerManager = sender.representedObject as? TimerManager else { return }
        timerManager.reset()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    func updateDisplay(for timerManager: TimerManager, label: String, symbolName: String, textColor: NSColor) {
        guard let index = trackers.firstIndex(where: { $0 === timerManager }),
              let button = statusItems[index].button else { return }

        let formattedTime = timerManager.formatTimeInterval(timerManager.remainingTime)
        if let image = createImageFromNumber(label: label, time: timerManager.remainingTime, symbolName: symbolName, textColor: textColor) {
            button.image = image
        } else {
            button.title = formattedTime
        }
    }

    func createImageFromNumber(label: String, time: TimeInterval, symbolName: String, textColor: NSColor) -> NSImage? {
        guard let arrowImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
            return nil
        }
        arrowImage.isTemplate = true

        let text = "\(label)\(formatTimeInterval(time))"
        
        let attributes = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: textColor
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let arrowSize = arrowImage.size
        let totalWidth = textSize.width + arrowSize.width
        let totalHeight = max(textSize.height, arrowSize.height)
        
        let image = NSImage(size: NSMakeSize(totalWidth, totalHeight))
        image.lockFocus()
        
        // Draw the text
        text.draw(at: NSPoint(x: 0, y: (totalHeight - textSize.height) / 2), withAttributes: attributes)
        
        // Create a tinted version of the arrow image
        if let tintedArrowImage = arrowImage.copy() as? NSImage {
            tintedArrowImage.lockFocus()
            textColor.set()
            let imageRect = NSRect(origin: .zero, size: arrowSize)
            imageRect.fill(using: .sourceAtop)
            tintedArrowImage.unlockFocus()
            
            // Draw the tinted arrow image
            tintedArrowImage.draw(at: NSPoint(x: textSize.width, y: (totalHeight - arrowSize.height) / 2), from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        
        image.unlockFocus()
        
        return image
    }

    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
