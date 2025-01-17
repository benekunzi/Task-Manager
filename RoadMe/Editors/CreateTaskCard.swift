//
//  CreateTaskCard.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 23.12.24.
//
import SwiftUI

struct CreateTaskCardView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @StateObject var newTask: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "",
        isCompleted: false)
    @State private var selectedColor: String = ""
    
    @ObservedObject var themeManger: ThemeManager = ThemeManager()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: "xmark")
                    .font(.system(size: 16).weight(.bold))
                    .padding(5)
                    .foregroundStyle(Color("LightGray"))
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
                    .onTapGesture {projectModel.showTaskEditor = false}
                Spacer()
                CreateTaskButtonView(newTask: newTask, selectedColor: $selectedColor)
            }
            .padding(.horizontal)
            .padding(.top)
            
            VStack(alignment: .leading, spacing: 25) {
                CardTopView(newTask: newTask)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Task Color")
                        .font(.system(size: 20).weight(.bold))
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(self.projectModel.selectedTheme.colorPalette, id: \.self) {color in
                                Circle()
                                    .strokeBorder(.gray, lineWidth: 1)
                                    .background(Circle().fill(Color(color)))
                                    .frame(width: 35, height: 35)
                                    .onTapGesture {
                                        self.selectedColor = color
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(selectedColor == "" ? projectModel.selectedTheme.colorPalette.first! : selectedColor))
        .foregroundStyle(Color("TextColor"))
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            self.selectedColor = self.projectModel.selectedTheme.colorPalette.first!
        }
    }
}

struct CreateTaskButtonView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @StateObject var newTask: ProjectTask
    @Binding var selectedColor: String
    
    var body: some View {
        Button {
            if newTask.name != "" {
                let selectedTask = projectModel.selectedTask
                newTask.color = selectedColor
                newTask.index = Int32(selectedTask.subtasks.count)
                newTask.parentTaskId = selectedTask.id
                self.projectModel.projectsTasks = self.coreDataModel.addSubtask(to: selectedTask.id, subtask: newTask)
                if let updatedTask = findTask(in: projectModel.projectsTasks, withID: selectedTask.id) {
                    projectModel.changeSelectedTask(task: updatedTask)
                } else {
                    print("task wasnt found")
                    projectModel.changeSelectedTask(task: projectModel.default_Project)
                }
                self.projectModel.showTaskEditor = false
            }
        } label: {
            if newTask.name != "" {
                Text("Create Task")
                    .font(.system(size: 16).weight(.bold))
                    .foregroundColor(Color("LightGray"))
                    .padding(5)
                    .padding(.horizontal, 3)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
            } else {
                Text("Create Task")
                    .font(.system(size: 16).weight(.bold))
                    .foregroundColor(Color.gray)
                    .padding(5)
                    .padding(.horizontal, 3)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))

            }
        }
    }
}

struct CardTopView: View {
    @StateObject var newTask: ProjectTask
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(newTask.name == "" ? "Task Name" : newTask.name,
                      text: $newTask.name)
            .autocorrectionDisabled()
            .font(.system(size: 22))
            
            TextField(newTask.description == "" ? "Add description" : newTask.description,
                      text: $newTask.description)
                .font(.system(size: 14))
                .padding(.vertical, 3)
                .autocorrectionDisabled()
        }
    }
}

struct TaskOptionOverlayView: View {
    
    @Binding var showMoreOptions: Bool
    @ObservedObject var task: ProjectTask
    
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var projectModel: ProjectModel
    
    var body: some View {
        VStack {
            HStack {
                if (showMoreOptions) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(2)
                        .foregroundStyle(Color.red)
                        .font(.system(size: 16))
                        .offset(x: -10, y: -10)
                        .onTapGesture {
                            let newTasks = coreDataModel.deleteTask(withID: task.id)
                            self.projectModel.projectsTasks = newTasks
                            // Find the selectedTask recursively in the updated structure
                            if let updatedTask = findTask(in: projectModel.projectsTasks, withID: projectModel.selectedTask.id) {
                                projectModel.changeSelectedTask(task: updatedTask)
                            } else {
                                projectModel.changeSelectedTask(task: projectModel.default_Project)
                            }
                        }
                }
                Spacer()
            }
            Spacer()
        }
    }
}

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle()
                .fill(Color("TextColor").opacity(0.1))
                .frame(height: 2)
                .padding(.top, 35))
            .padding(10)
    }
}

#Preview {
    ContentView()
}
