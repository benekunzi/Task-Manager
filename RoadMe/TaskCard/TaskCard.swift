//
//  TaskCard.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI

struct TaskCard: View {
    @ObservedObject var task: ProjectTask
    @Binding var showMoreOptions: Bool
    @Binding var isWiggling: Bool
    @Binding var numberOfColumns: Int
    @Binding var scale: CGFloat
    @Binding var showSubtasks: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @State private var isPressed: Bool = false
    
    var body: some View {
        TaskCardContentView(task: task,
                            numberOfColumns: $numberOfColumns,
                            scale: $scale,
                            showSubstasks: $showSubtasks)
            .background(
                RoundedRectangle(cornerRadius: 10 * scale)
                    .fill(Color.white)
                    .shadow(color: Color("LightGray"), radius: 2, x: 0, y: 2)
            )
            .frame(height: showSubtasks ? (150 * scale) : (75 * scale))
            .onTapGesture(count: 1) {
                Task {
                    print("Tap Gesture. \(Date().timeIntervalSince1970)")
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    if (showMoreOptions) {
                        showMoreOptions = false
                    } else {
                        
                        projectModel.offsetTaskCards = -UIScreen.main.bounds.height
                        
                        try? await Task.sleep(nanoseconds: 250_000_000)
                        
                        task.parentTaskId = self.projectModel.selectedTask.id
                        self.projectModel.changeSelectedTask(task: task)
                        projectModel.offsetTaskCards = UIScreen.main.bounds.height
                        
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        
                        projectModel.offsetTaskCards = 0
                    }
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded() { value in
                        print("LongPressGesture started. \(Date().timeIntervalSince1970)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                            impactMed.impactOccurred()
                            if (!showMoreOptions) {
                                showMoreOptions = true
                                                        }
                        })
                    }
                    .sequenced(before:TapGesture(count: 1)
                        .onEnded {
                            print("LongPressGesture ended. \(Date().timeIntervalSince1970)")
                        }
                    )
            )
            .overlay(
                task.isCompleted ? nil : TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
            )
            .rotationEffect(.degrees(task.isCompleted || !isWiggling ? 0 : 2.5)) // No rotation for completed tasks
            .rotation3DEffect(
                .degrees(0),
                axis: (x: 0, y: task.isCompleted ? 0 : -5, z: 0)
            )
            .animation(
                isWiggling && !task.isCompleted
                ? Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true)
                : .default, // Default stops the animation
                value: isWiggling
            )
    }
}
