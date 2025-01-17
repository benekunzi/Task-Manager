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
    
    @StateObject var lastTask: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "BlushPink",
        isCompleted: false)
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack() {
                    Image(systemName: "xmark")
                        .font(.system(size: 16).weight(.bold))
                        .padding(5)
                        .foregroundStyle(Color("LightGray"))
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
                        .onTapGesture {projectModel.showEditTaskEditor = false}
                    
                    Spacer()
                    
                    EditTaskButtonView(lastTask: lastTask)
                }
                .padding(.horizontal)
                .padding(.top)

                VStack(alignment: .leading, spacing: 15) {
                    CardTopView(newTask: lastTask)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Card Color")
                            .font(.system(size: 20).weight(.bold))
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(self.projectModel.selectedTheme.colorPalette, id: \.self) {color in
                                    Circle()
                                        .strokeBorder(.gray, lineWidth: 1)
                                        .background(Circle().fill(Color(color)))
                                        .frame(width: 35, height: 35)
                                        .onTapGesture {
                                            lastTask.color = color
                                        }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Task Icon")
                            .font(.system(size: 20).weight(.bold))
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(lastTask.color))
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
                    if let updatedTask = findTask(in: projectModel.projectsTasks, withID: lastTask.id) {
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
                    Text("Update Project")
                        .font(.system(size: 16).weight(.bold))
                        .foregroundColor(Color("LightGray"))
                        .padding(5)
                        .padding(.horizontal, 3)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
                } else {
                    Text("Update Project")
                        .font(.system(size: 16).weight(.bold))
                        .foregroundColor(Color.gray)
                        .padding(5)
                        .padding(.horizontal, 3)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
                }
            }
        } else {
            EmptyView()
        }
    }
}
