//
//  TimerItem.swift
//  KeepTimeLite
//
//  Created by Nishchay Karle on 5/23/24.
//

import Cocoa

class TimerManager {

    private var timer: Timer?
    private(set) var remainingTime: TimeInterval
    private let initialTime: TimeInterval
    private let isCountingUp: Bool
    private(set) var isPaused: Bool = false

    var onUpdate: (() -> Void)?

    init(startTime: TimeInterval, isCountingUp: Bool) {
        self.initialTime = startTime
        self.remainingTime = isCountingUp ? 0 : startTime
        self.isCountingUp = isCountingUp
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isPaused = false
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isPaused = true
    }

    func reset() {
        remainingTime = isCountingUp ? 0 : initialTime
        onUpdate?()
    }

    @objc private func updateTimer() {
        if isCountingUp {
            remainingTime += 1
        } else {
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stop()
            }
        }
        onUpdate?()
    }
    
    @objc func pauseOrResume() {
        if isPaused {
            start()
        }
        else {
            stop()
        }
    }

    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
