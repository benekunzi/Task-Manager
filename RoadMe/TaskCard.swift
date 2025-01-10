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
    
    @State var taskName: String = ""
    @State private var orientation = UIDeviceOrientation.unknown
    
    let taskColor = Color("BlushPink")
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: task.isCompleted ? "checkmark.circle" : "circle")
                        .font(.system(size: 14).bold())
                        .onTapGesture {
                            projectModel.updateCompleteStatus(task: task)
                            coreDataModel.updateIsCompleted(taskID: task.id, isCompleted: task.isCompleted)
                            projectModel.projectsTasks.first(where: { $0.id == projectModel.selectedProject!.id })!.calculateProcess()
                        }
                    Text(task.name)
                        .lineLimit(1)
                        .font(.system(
                            size: TextSizeLookup.getFontSize(
                                for: numberOfColumns,
                                deviceType: projectModel.deviceType,
                                orientation: .vertical,
                                textType: .title)).bold())
                    Spacer()
                }
                Text(task.description)
                    .font(.system(size:
                                    TextSizeLookup.getFontSize(
                                        for: numberOfColumns,
                                        deviceType: projectModel.deviceType,
                                        orientation: .vertical,
                                        textType: .description)))
                    .lineLimit(1)
                    .foregroundStyle(Color.gray)
                HStack {
                    Spacer()
                    Text("\(task.subtasks.filter(\.isCompleted).count)/\(task.subtasks.count)")
                }
                .font(.system(size:
                                TextSizeLookup.getFontSize(
                                    for: numberOfColumns,
                                    deviceType: projectModel.deviceType,
                                    orientation: .vertical,
                                    textType: .description)))
                .foregroundStyle(Color.gray)
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
                                                    textType: .subtask)))
                            Spacer()
                        }
                    }
                }
                Spacer()
            }.frame(maxWidth: .infinity)
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.gray)
                        .font(.system(size: 16))
                        .onTapGesture {
                            projectModel.taskToEdit = task
                            self.projectModel.showEditTaskEditor.toggle()
                        }
                }
                Spacer()
            }
        }
        .foregroundStyle(Color("TextColor").opacity(0.75))
        .padding(10)
        .background(ZStack {
            Color.white
        })
        .frame(height: CardSHeightLookUp.getCardHeight(for: numberOfColumns, deviceType: projectModel.deviceType, orientation: orientation))
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
//        .padding(.horizontal)
        .modifier(ProcessBorderModifier(process: task.process, color: Color.red))
        .overlay(
            TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
        )
        .onChange(of: self.taskName) { newValue in
            task.name = newValue
        }
        .onTapGesture {
            if (!showMoreOptions) {
                task.parentTaskId = self.projectModel.selectedTask.id
                self.projectModel.changeSelectedTask(task: task)
            } else {
                showMoreOptions = false
            }
        }
        .onLongPressGesture {
            if (!showMoreOptions) {
                showMoreOptions = true
            }
        }
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

#Preview {
    ContentView()
}

struct ProcessBorderModifier: ViewModifier {
    var process: Double // Value between 0 and 1
    var color: Color
    var lineWidth: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    // Right Top Corner
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .trim(from: 0.75, to: 0.75 + min(mapProcess(minDomain: 0, maxDomain: 0.5, value: process), 0.25))
                        .glow(fill: Color.red, lineWidth: lineWidth)
                        .rotationEffect(.degrees(0)) // Default orientation

                    // Left Side
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .trim(from: 0.75 - min(mapProcess(minDomain: 0, maxDomain: 0.5, value: process), 0.25), to: 0.75)
                        .glow(fill: Color.red, lineWidth: lineWidth)
                        .rotationEffect(.degrees(0)) // Default orientation

                    // Right Bottom Side
                    if process > 0.5 {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .trim(from: 0 , to: min(mapProcess(minDomain: 0, maxDomain: 0.25, value: process), 0.25))
                            .glow(fill: Color.red, lineWidth: lineWidth)
                            .rotationEffect(.degrees(0)) // Default orientation
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .trim(from: 0.5 - min(mapProcess(minDomain: 0, maxDomain: 0.25, value: process), 0.25) , to: 0.5)
                            .glow(fill: Color.red, lineWidth: lineWidth)
                            .rotationEffect(.degrees(0)) // Default orientation
                    }
                }
            )
    }
}


extension View where Self: Shape {
  func glow(
    fill: some ShapeStyle,
    lineWidth: Double,
    blurRadius: Double = 4.0,
    lineCap: CGLineCap = .round
  ) -> some View {
    self
      .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
      .fill(fill)
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius)
      }
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius / 2)
      }
  }
}

func mapProcess(minDomain:Double, maxDomain:Double, value:Double) -> Double {
    return minDomain + (maxDomain - minDomain) * (value - 0) / (1 - 0)
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
