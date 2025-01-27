//
//  Pomodoro.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 26.01.25.
//

import SwiftUI
import Combine

// MARK: - Pomodoro Timer Logic Class
class PomodoroTimer: ObservableObject {
    enum TimerState: Int, CaseIterable {
        case flow, shortBreak, flow2, longBreak

        var displayName: String {
            switch self {
            case .flow, .flow2: return "Flow"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
    }

    @Published var timeRemaining: Int = 25 * 60 // Default 25 minutes
    @Published var isRunning: Bool = false
    @Published var currentState: TimerState = .flow
    @Published var hasStarted: Bool = false

    private var cancellable: AnyCancellable?
    private let durations = [
        TimerState.flow: 25 * 60,
        TimerState.shortBreak: 5 * 60,
        TimerState.flow2: 25 * 60,
        TimerState.longBreak: 15 * 60
    ]

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        hasStarted = true

        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stopTimer() {
        isRunning = false
        cancellable?.cancel()
    }

    func resetTimer() {
        stopTimer()
        hasStarted = false
        timeRemaining = durations[currentState] ?? 0
    }

    private func tick() {
        guard timeRemaining > 0 else {
            advanceState()
            return
        }

        timeRemaining -= 1
    }

    private func advanceState() {
        stopTimer()

        if let nextState = TimerState(rawValue: (currentState.rawValue + 1) % TimerState.allCases.count) {
            currentState = nextState
            timeRemaining = durations[currentState] ?? 0
        }
    }

    func progress(for state: TimerState) -> Double {
        guard let totalDuration = durations[state] else { return 0 }
        if state == currentState {
            return 1 - Double(timeRemaining) / Double(totalDuration)
        } else if state.rawValue < currentState.rawValue {
            return 1
        } else {
            return 0
        }
    }

    func totalTime(for state: TimerState) -> Int {
        return durations[state] ?? 0
    }
}
