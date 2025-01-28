//
//  Focus.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 25.01.25.
//

import SwiftUI

// MARK: - Pomodoro App Main View
struct FocusView: View {
    @StateObject private var pomodoroTimer = PomodoroTimer()
    
    private let fontModel: FontModel = FontModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button {
                    pomodoroTimer.resetTimer()
                } label:{
                    Text("Reset")
                }
            }

            Spacer()

            Text(pomodoroTimer.currentState.displayName)
                .font(.custom(fontModel.font_body_medium, size: 28))
                .foregroundStyle(Color.black)
            
            VStack(spacing: 10) {
                Text(formatTime(seconds: pomodoroTimer.timeRemaining))
                    .font(.custom(fontModel.font_title, size: 80))
                    .foregroundStyle(Color.black)

                HStack(spacing: 10) {
                    ForEach(PomodoroTimer.TimerState.allCases, id: \.self) { state in
                        if state == pomodoroTimer.currentState && (pomodoroTimer.isRunning || pomodoroTimer.hasStarted) {
                            VStack {
                                ProgressView(value: Double(pomodoroTimer.totalTime(for: state)) - Double(pomodoroTimer.timeRemaining),
                                             total: Double(pomodoroTimer.totalTime(for: state)))
                                    .progressViewStyle(CustomProgressBar())
                            }
                        } else {
                            Circle()
                                .fill(state.rawValue < pomodoroTimer.currentState.rawValue ? Color.green : Color.green.opacity(0.2))
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
            
            Button {
                if pomodoroTimer.isRunning {
                    pomodoroTimer.stopTimer()
                } else {
                    pomodoroTimer.startTimer()
                }
            } label: {
                Image(systemName: pomodoroTimer.isRunning ? "pause" : "play")
            }
            .foregroundStyle(Color.green)
            .font(.system(size: 28))

            Spacer()
        }
        .padding()
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CustomProgressBar: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.green.opacity(0.2))
                .frame(width: 50, height: 14)
            Capsule()
                .frame(width: 50 * CGFloat(configuration.fractionCompleted ?? 0.0), height: 14)
                .foregroundColor(.green)
        }
        .clipShape(Capsule())
    }
}
