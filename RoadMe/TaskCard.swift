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
    @Binding var taskCardWidth: CGFloat
    @Binding var numberOfColumns: Int
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var isTapped: Bool = false
    @State private var isPressed: Bool = false
    
    var body: some View {
        ZStack {
            
            TaskCardContentView(task: task, numberOfColumns: $numberOfColumns)
            
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color("LightGray"))
                        .font(.system(size: 16).weight(.bold))
                        .onTapGesture {
                            projectModel.taskToEdit = task
                            self.projectModel.showEditTaskEditor.toggle()
                        }
                }
                Spacer()
            }
        }
        .modifier(ChunkyButtonModifier(isTap: $isTapped, color: $task.color))
        .frame(height: CardSHeightLookUp.getCardHeight(for: numberOfColumns, deviceType: projectModel.deviceType, orientation: orientation))
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
//            .overlay(
//                RoundedRectangle(cornerRadius: 20, style: .continuous)
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .overlay(
                TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
            )
            .onRotate { newOrientation in
                orientation = newOrientation
            }
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
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: task.isCompleted ? "checkmark.circle" : "circle")
                    .font(.system(size: 14).weight(.bold))
                    .foregroundStyle(Color("LightGray"))
                    .onTapGesture {
                        projectModel.updateCompleteStatus(task: task)
                        coreDataModel.updateIsCompleted(taskID: task.id, isCompleted: task.isCompleted)
                        _ = projectModel.projectsTasks.first(where: { $0.id == projectModel.selectedProject!.id })!.calculateProcess()
                    }
                Text(task.name)
                    .lineLimit(1)
                    .font(.system(
                        size: TextSizeLookup.getFontSize(
                            for: numberOfColumns,
                            deviceType: projectModel.deviceType,
                            orientation: .vertical,
                            textType: .title)).weight(.bold))
                Spacer()
            }
            Text(task.description)
                .font(.system(size:
                                TextSizeLookup.getFontSize(
                                    for: numberOfColumns,
                                    deviceType: projectModel.deviceType,
                                    orientation: .vertical,
                                    textType: .description)).weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(Color("LightGray"))
            HStack {
                Spacer()
                Text("\(task.subtasks.filter(\.isCompleted).count)/\(task.subtasks.count)")
            }
            .font(.system(size:
                            TextSizeLookup.getFontSize(
                                for: numberOfColumns,
                                deviceType: projectModel.deviceType,
                                orientation: .vertical,
                                textType: .description)).weight(.semibold))
            .foregroundStyle(Color("LightGray"))
            Spacer()
            VStack(alignment: .leading) {
                ForEach(task.subtasks.filter({$0.isCompleted == false}).prefix(3)) { subtask in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                        Text(subtask.name)
                            .font(.system(size:
                                            TextSizeLookup.getFontSize(
                                                for: numberOfColumns,
                                                deviceType: projectModel.deviceType,
                                                orientation: .vertical,
                                                textType: .subtask)).weight(.semibold))
                        Spacer()
                    }
                }
            }
        }.frame(maxWidth: .infinity)
    }
}

struct ChunkyButtonModifier: ViewModifier {
    
    @Binding var isTap: Bool
    @Binding var color: String
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    // Background shadow for 3D effect
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.black)
                            RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(color).opacity(0.5))
                        })
                        .offset(y: isTap ? 0 : 5)
                        .animation(.easeInOut(duration: 0.1), value: isTap) // Animation for shadow
                    // Foreground button
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(color)))
                }
            )
            .offset(y: isTap ? 5 : 0) // Button movement animation
            .animation(.easeInOut(duration: 0.1), value: isTap) // Smooth animation
    }
}

struct WelcomeChunkyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    // Background shadow for 3D effect
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color("Theme-1-VeryDarkGreen")))
                        .offset(y: configuration.isPressed ? 0 : 5)
                        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) // Animation for shadow
                    // Foreground button
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.white))
                }
            )
            .onChange(of: configuration.isPressed) { _ in print("changed")}
            .offset(y: configuration.isPressed ? 5 : 0) // Button movement animation
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) // Smooth animation
        
    }
}

struct WelcomeChunkyButtonModifier: ViewModifier {
    
    @Binding var isTap: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Background shadow for 3D effect
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color("Theme-1-VeryDarkGreen")))
                        .offset(y: isTap ? 0 : 5)
                        .animation(.easeInOut(duration: 0.1), value: isTap) // Animation for shadow
                    // Foreground button
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.white))
                }
            )
            .offset(y: isTap ? 5 : 0) // Button movement animation
            .animation(.easeInOut(duration: 0.1), value: isTap) // Smooth animation
    }
}

#Preview {
    ContentView()
}
