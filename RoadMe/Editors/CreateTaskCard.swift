//
//  CreateTaskCard.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 23.12.24.
//
import SwiftUI

struct CreateAndUpdateTaskCardView: View {
    
    let updateExistingTask: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var newTask: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "",
        isCompleted: false)
    @State private var selectedColor: String = ""
    // Vibration
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                Text("Cancel")
                    .font(.custom("Inter-Regular_Medium", size: 16))
                    .foregroundStyle(Color.black)
                    .onTapGesture {
                        if updateExistingTask {
                            self.projectModel.showEditTaskEditor = false
                        } else {
                            self.projectModel.showTaskEditor = false
                        }
                    }
                Spacer()
                
                if updateExistingTask {
                    EditTaskButtonView(lastTask: newTask)
                } else {
                    CreateTaskButtonView(newTask: newTask)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    CardTopView(newTask: newTask)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Task Color")
                            .font(.custom("Inter-Regular_Medium", size: 18))
                            .foregroundStyle(Color.black)
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
                                        impactMed.impactOccurred()
                                        selectedColor = "green"
                                    }
                                Circle()
                                    .strokeBorder(.gray, lineWidth: 1)
                                    .background(Circle().fill(Color(blue)))
                                    .frame(width: 35, height: 35)
                                    .onTapGesture {
                                        impactMed.impactOccurred()
                                        selectedColor = "blue"
                                    }
                                Circle()
                                    .strokeBorder(.gray, lineWidth: 1)
                                    .background(Circle().fill(Color(purple)))
                                    .frame(width: 35, height: 35)
                                    .onTapGesture {
                                        impactMed.impactOccurred()
                                        selectedColor = "purple"
                                    }
                            }
                        }
                    }
                    CalendarView(color: self.$selectedColor, newTask: newTask)
                    Spacer()
                }.padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .foregroundStyle(Color("TextColor"))
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            self.selectedColor = "green"
            if updateExistingTask {
                if let taskToEdit = projectModel.taskToEdit {
                    newTask.id              = taskToEdit.id
                    newTask.subtasks        = taskToEdit.subtasks
                    newTask.name            = taskToEdit.name
                    newTask.description     = taskToEdit.description
                    newTask.color           = taskToEdit.color
                    newTask.isCompleted     = taskToEdit.isCompleted
                    newTask.index           = taskToEdit.index
                    newTask.process         = taskToEdit.process
                    newTask.iconString      = taskToEdit.iconString
                    newTask.iconImage       = taskToEdit.iconImage
                    newTask.parentTaskId    = taskToEdit.parentTaskId
                    newTask.coverImage      = taskToEdit.coverImage
                    newTask.date            = taskToEdit.date
                }
                print(newTask.color)
            }
        }
        .onDisappear {
            self.projectModel.taskToEdit = nil
        }
        .onChange(of: self.selectedColor) { newValue in
            newTask.color = newValue
        }
        .animation(.easeInOut(duration: 0.25), value: self.selectedColor)
    }
}

struct CreateTaskButtonView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @StateObject var newTask: ProjectTask
    
    var body: some View {
        Button {
            if newTask.name != "" {
                print("create new task")
                let selectedTask = projectModel.selectedTask
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
                Text("Done")
                    .font(.custom("Inter-Regular_Medium", size: 16))
                    .foregroundStyle(Color.black)
            } else {
                Text("Done")
                    .font(.custom("Inter-Regular_Medium", size: 16))
                    .foregroundStyle(Color("Gray"))
            }
        }
    }
}

struct CardTopView: View {
    @StateObject var newTask: ProjectTask
    @FocusState var isKeyboardFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(newTask.name == "" ? "Task Name" : newTask.name,
                      text: $newTask.name)
            .font(.custom("Inter-Regular_Medium", size: 18))
            .foregroundStyle(Color.black)
            .autocorrectionDisabled()
            .focused($isKeyboardFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isKeyboardFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }

                    
                }
            }
            if #available(iOS 16.0, *) {
                TextField(newTask.description == "" ? "Add description" : newTask.description,
                          text: $newTask.description, axis: .vertical)
                .font(.custom("Inter-Regular_Medium", size: 18))
                .foregroundStyle(Color.gray)
                .padding(.vertical, 3)
                .focused($isKeyboardFocused)
            } else {
                TextField(newTask.description == "" ? "Add description" : newTask.description,
                          text: $newTask.description)
                .font(.custom("Inter-Regular_Medium", size: 18))
                .foregroundStyle(Color.gray)
                .padding(.vertical, 3)
                .focused($isKeyboardFocused)
            }
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
                    (lastTask.color != taskToEdit.color) ||
                    (lastTask.date != taskToEdit.date)) {
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
                    (lastTask.color != taskToEdit.color) ||
                    (lastTask.date != taskToEdit.date)) {
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
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
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
