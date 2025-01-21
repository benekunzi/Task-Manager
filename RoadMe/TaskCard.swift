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
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @State private var isTapped: Bool = false
    @State private var isPressed: Bool = false
    
    var body: some View {
        TaskCardContentView(task: task, numberOfColumns: $numberOfColumns, scale: $scale)
            .background(
                RoundedRectangle(cornerRadius: 10 * scale)
                    .fill(Color.white)
                    .shadow(color: Color("LightGray"), radius: 2, x: 0, y: 2)
            )
            .frame(height: 150 * scale)
            .onTapGesture(count: 1) {
                print("Tap Gesture. \(Date().timeIntervalSince1970)")
                self.isTapped = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    if (!showMoreOptions) {
                        task.parentTaskId = self.projectModel.selectedTask.id
                        self.projectModel.changeSelectedTask(task: task)
                    } else {
                        showMoreOptions = false
                    }
                    isTapped = false
                })
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded() { value in
                        print("LongPressGesture started. \(Date().timeIntervalSince1970)")
                        self.isTapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            if (!showMoreOptions) {
                                showMoreOptions = true
                                self.isTapped = false
                            }
                        })
                    }
                    .sequenced(before:TapGesture(count: 1)
                        .onEnded {
                            print("LongPressGesture ended. \(Date().timeIntervalSince1970)")
                            self.isTapped = false
                        }
                    )
            )
            .overlay(
                TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
            )
            .rotationEffect(.degrees(isWiggling ? 2.5 : 0))
            .rotation3DEffect(.degrees(0), axis: (x: 0, y: -5, z: 0))
            .animation(
                isWiggling
                ? Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true)
                : .default, // Default stops the animation
                value: isWiggling
            )
    }
}
    
struct TaskCardContentView: View {
    
    @ObservedObject var task: ProjectTask
    @Binding var numberOfColumns: Int
    @Binding var scale: CGFloat
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var orientation = UIDeviceOrientation.unknown
    private let taskNameSize: CGFloat = 16
    private let taskDescriptionSize: CGFloat = 14
    private let subtaskNameSize: CGFloat = 12
    private let checkBoxSize: CGFloat = 22
    private let subtaskCheckBoxSize: CGFloat = 14
    private let infoButtonSize: CGFloat = 18
    private let taskCounterSize: CGFloat = 12
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .top, spacing: 10*scale) {
                    Image(systemName: task.isCompleted ? "circle.fill" : "circle")
                        .font(.system(size: checkBoxSize * scale).weight(.regular))
                        .foregroundStyle(Color(themeManager.currentTheme.colors[task.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                        .onTapGesture {
                            projectModel.updateCompleteStatus(task: task)
                            coreDataModel.updateIsCompleted(taskID: task.id, isCompleted: task.isCompleted)
                            _ = projectModel.projectsTasks.first(where: { $0.id == projectModel.selectedProject!.id })!.calculateProcess()
                        }
                    VStack(alignment: .leading, spacing: 4 * scale) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2 * scale) {
                                Text(task.name)
                                    .lineLimit(1)
                                    .font(.custom("Inter-Regular_SemiBold", size: taskNameSize * scale))
                                    .foregroundStyle(Color.black)
                                if (task.description != "") {
                                    Text(task.description)
                                        .font(.custom("Inter-Regular_Medium", size: taskDescriptionSize * scale))
                                        .foregroundStyle(Color("Gray"))
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Image(systemName: "info.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color(themeManager.currentTheme.colors[task.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary), Color(themeManager.currentTheme.colors[task.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary))
                                .font(.system(size: infoButtonSize * scale).weight(.bold))
                                .onTapGesture {
                                    projectModel.taskToEdit = task
                                    self.projectModel.showEditTaskEditor.toggle()
                                }
                        }
                        HStack {
                            Spacer()
                            if (task.subtasks.count > 0) {
                                Text("\(task.subtasks.filter(\.isCompleted).count)/\(task.subtasks.count)")
                                    .font(.custom("Inter-Regular_Medium", size: taskCounterSize * scale))
                                    .foregroundStyle(Color("Gray"))
                            }
                        }
                        VStack(alignment: .leading, spacing: 4 * scale) {
                            ForEach(task.subtasks.filter({$0.isCompleted == false}).prefix(3)) { subtask in
                                HStack(alignment: .center, spacing: 8 * scale) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .strokeBorder(Color("LightGray"), lineWidth: 1)
                                        .frame(width: subtaskCheckBoxSize * scale,
                                               height: subtaskCheckBoxSize * scale)
                                    Text(subtask.name)
                                        .font(.custom("Inter-Regular_Medium", size: subtaskNameSize * scale))
                                        .foregroundStyle(Color.black)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, self.horizontalPadding * scale)
        .padding(.top, 10 * scale)
        .frame(maxWidth: .infinity)
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

#Preview {
    ContentView()
}
