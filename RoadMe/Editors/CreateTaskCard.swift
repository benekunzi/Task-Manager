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
        color: "BlushPink",
        isCompleted: false)
    @State private var showPicker: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            TopImageView(newProject: newTask, showPicker: $showPicker, toggleEditor: self.$projectModel.showTaskEditor)
            VStack(alignment: .leading, spacing: 15) {
                CardTopView(newTask: newTask,
                            showPicker: $showPicker,
                            showImagePicker: $showImagePicker)
                
                ScrollView(.horizontal) {
                    HStack {
                        Circle()
                            .strokeBorder(.gray, lineWidth: 2)
                            .background(Circle().fill(Color(ColorPalette.blushPink)))
                            .frame(width: 35, height: 35)
                    }
                }
                Spacer()
            }
            .padding()
            
            CreateTaskButtonView(newTask: newTask)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .foregroundStyle(Color("TextColor"))
        .fullScreenCover(isPresented: self.$showPicker) {
            IconPicker(newProject: newTask, showPicker: $showPicker)
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        newTask.coverImage = inputImage
    }
}

struct CreateTaskButtonView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @StateObject var newTask: ProjectTask
    
    var body: some View {
        Button {
            if newTask.name != "" {
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
                Text("Create Task")
                    .padding()
                    .padding(.horizontal)
                    .foregroundColor(Color("TextColor"))
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color("TextColor"), lineWidth: 1))
            } else {
                Text("Create Task")
                    .padding()
                    .padding(.horizontal)
                    .foregroundColor(Color.gray)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            }
        }
    }
}

struct CardTopView: View {
    @StateObject var newTask: ProjectTask
    @Binding var showPicker: Bool
    @Binding var showImagePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 20) {
                if (newTask.iconString == nil && newTask.iconImage == nil) {
                    HStack {
                        Image(systemName: "face.smiling")
                        Text("Icon hinzufügen")
                    }.font(.system(size: 12))
                        .onTapGesture {
                            self.showPicker.toggle()
                        }
                }
                if (newTask.coverImage == nil) {
                    HStack(spacing: 5) {
                        Image(systemName: "doc")
                        Text("Cover hinzufügen")
                    }
                    .font(.system(size: 12))
                    .onTapGesture {
                        self.showImagePicker.toggle()
                    }
                }
            }
            
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
