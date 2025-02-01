//
//  TaskCardContent.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 25.01.25.
//

import SwiftUI

struct TaskCardContentView: View {
    
    @ObservedObject var task: ProjectTask
    @Binding var numberOfColumns: Int
    @Binding var scale: CGFloat
    @Binding var showSubstasks: Bool
    
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
            VStack(alignment: .center, spacing: 4 * scale) {
                HStack(alignment: .top, spacing: 10*scale) {
                    VStack(alignment: .leading, spacing: 8 * scale) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: checkBoxSize * scale).weight(.regular))
                            .foregroundStyle(Color(themeManager.currentTheme.colors[task.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                            .onTapGesture {
                                projectModel.updateCompleteStatus(task: task)
                                projectModel.projectsTasks = coreDataModel.updateIsCompleted(taskID: task.id, isCompleted: task.isCompleted, doneDate: task.doneDate)
                                if let updatedProject = findTask(in: projectModel.projectsTasks, withID: projectModel.selectedProject!.id) {
                                    projectModel.updateSelectedProject(project: updatedProject)
                                    if let project = projectModel.calculateProcessForSelectedProject() {
                                        projectModel.projectsTasks = coreDataModel.updateProcessForProject(project)
                                        if let updatedTask = findTask(in: projectModel.projectsTasks, withID: projectModel.selectedTask.id) {
                                            projectModel.changeSelectedTask(task: updatedTask)
                                        }
                                    }
                                }
                            }
                        VStack(alignment: .center, spacing: 4 * scale) {
                            ProgressView(value: task.process, total: 1.0)
                                .progressViewStyle(.linear)
                                .tint(Color(themeManager.currentTheme.colors[task.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                                .frame(width: 30 * scale)
                            if showSubstasks {
                                Text("\(Int(task.process * 100))%")
                                    .font(.custom(GhibliFont.medium.name, size: taskDescriptionSize * scale))
                                    .foregroundStyle(Color("Gray"))
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 8 * scale) {
                        // MARK: For name, description and info
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2 * scale) {
                                Text(task.name)
                                    .lineLimit(1)
                                    .font(.custom(GhibliFont.semiBold.name, size: taskNameSize * scale))
                                    .foregroundStyle(Color.black)
                                if (task.description != "") {
                                    Text(task.description)
                                        .font(.custom(GhibliFont.medium.name, size: taskDescriptionSize * scale))
                                        .foregroundStyle(Color("Gray"))
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color(themeManager.currentTheme.colors[task.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary), Color(themeManager.currentTheme.colors[task.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary))
                                .font(.system(size: infoButtonSize * scale).weight(.bold))
                                .onTapGesture {
                                    projectModel.taskToEdit = task
                                    self.projectModel.showEditTaskEditor.toggle()
                                }
                        }
                        if showSubstasks {
                            // MARK: For date and counter
                            HStack {
                                if let date = task.dueDate {
                                    Text(date, format: .dateTime)
                                        .font(.custom(GhibliFont.medium.name, size: taskCounterSize * scale))
                                        .foregroundStyle(Color("Gray"))
                                }
                                Spacer()
                                if (task.subtasks.count > 0) {
                                    Text("\(task.subtasks.filter(\.isCompleted).count)/\(task.subtasks.count)")
                                        .font(.custom(GhibliFont.medium.name, size: taskCounterSize * scale))
                                        .foregroundStyle(Color("Gray"))
                                }
                            }
                            // MARK: For subtasks
                        
                            VStack(alignment: .leading, spacing: 4 * scale) {
                                ForEach(task.subtasks.filter({$0.isCompleted == false}).prefix(3)) { subtask in
                                    HStack(alignment: .center, spacing: 8 * scale) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .strokeBorder(Color("LightGray"), lineWidth: 1)
                                            .frame(width: subtaskCheckBoxSize * scale,
                                                   height: subtaskCheckBoxSize * scale)
                                        Text(subtask.name)
                                            .font(.custom(GhibliFont.medium.name, size: subtaskNameSize * scale))
                                            .foregroundStyle(Color.black)
                                        Spacer()
                                    }
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
