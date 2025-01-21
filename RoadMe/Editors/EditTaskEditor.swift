//
//  EditTaskEditor.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 06.01.25.
//

import SwiftUI

struct EditTaskEditor: View {
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var lastTask: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "",
        isCompleted: false)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack() {
                Text("Cancel")
                    .font(.custom("Inter-Regular_Medium", size: 16))
                    .foregroundStyle(Color.black)
                    .onTapGesture {projectModel.showEditTaskEditor = false}
                
                Spacer()
                
                EditTaskButtonView(lastTask: lastTask)
            }
            .padding(.horizontal)
            .padding(.top)

            VStack(alignment: .leading, spacing: 24) {
                CardTopView(newTask: lastTask)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Card Accent Color")
                        .font(.custom("Inter-Regular_Medium", size: 18))
                        .foregroundStyle(lastTask.color == "" ? Color.black : Color(themeManager.currentTheme.colors[lastTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                    ScrollView(.horizontal) {
                        HStack(spacing: 15) {
                            let green = projectModel.selectedTheme.colors["green"]!.primary
                            let blue = projectModel.selectedTheme.colors["blue"]!.primary
                            let purple = projectModel.selectedTheme.colors["purple"]!.primary
                            Circle()
                                .strokeBorder(.gray, lineWidth: 1)
                                .background(Circle().fill(Color(green)))
                                .frame(width: 35, height: 35)
                                .onTapGesture {
                                    lastTask.color = "green"
                                }
                            Circle()
                                .strokeBorder(.gray, lineWidth: 1)
                                .background(Circle().fill(Color(blue)))
                                .frame(width: 35, height: 35)
                                .onTapGesture {
                                    lastTask.color = "blue"
                                }
                            Circle()
                                .strokeBorder(.gray, lineWidth: 1)
                                .background(Circle().fill(Color(purple)))
                                .frame(width: 35, height: 35)
                                .onTapGesture {
                                    lastTask.color = "purple"
                                }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Task Icon")
                        .font(.custom("Inter-Regular_Medium", size: 18))
                        .foregroundStyle(lastTask.color == "" ? Color.black : Color(themeManager.currentTheme.colors[lastTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .foregroundStyle(Color("TextColor"))
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if let taskToEdit = projectModel.taskToEdit {
                lastTask.id = taskToEdit.id
                lastTask.subtasks = taskToEdit.subtasks
                lastTask.name = taskToEdit.name
                lastTask.description = taskToEdit.description
                lastTask.color = taskToEdit.color
                lastTask.isCompleted = taskToEdit.isCompleted
                lastTask.index = taskToEdit.index
                lastTask.process = taskToEdit.process
                lastTask.iconString = taskToEdit.iconString
                lastTask.iconImage = taskToEdit.iconImage
                lastTask.parentTaskId = taskToEdit.parentTaskId
                lastTask.coverImage = taskToEdit.coverImage
            }
            print(lastTask.color)
        }
        .onDisappear {
            self.projectModel.taskToEdit = nil
        }
    }
}

struct EditTaskButtonView: View {
    
    @StateObject var lastTask: ProjectTask
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    var body: some View {
        if let taskToEdit = projectModel.taskToEdit {
            Button {
                if ((lastTask.name != taskToEdit.name) ||
                    (lastTask.description != taskToEdit.description) ||
                    (lastTask.color != taskToEdit.color)) {
                    self.projectModel.projectsTasks = self.coreDataModel.updateTask(taskToEdit: lastTask)
                    if let updatedTask = findTask(in: projectModel.projectsTasks, withID: lastTask.parentTaskId!) {
                        print("updated task in editor")
                        for subtask in updatedTask.subtasks {
                            print(subtask.color)
                        }
                        projectModel.changeSelectedTask(task: updatedTask)
                        projectModel.showEditTaskEditor = false
                    } else {
                        print("task wasnt found")
                        projectModel.changeSelectedTask(task: projectModel.default_Project)
                    }
                }
            } label: {
                if ((lastTask.name != taskToEdit.name) ||
                    (lastTask.description != taskToEdit.description) ||
                    (lastTask.color != taskToEdit.color)) {
                    Text("Done")
                        .font(.custom("Inter-Regular_Medium", size: 16))
                        .foregroundStyle(Color.black)
                } else {
                    Text("Done")
                        .font(.custom("Inter-Regular_Medium", size: 16))
                        .foregroundStyle(Color("Gray"))
                }
            }
        } else {
            EmptyView()
        }
    }
}
