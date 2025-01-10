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
    
    @State private var showPicker: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var inputImage: UIImage?
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
                TopImageView(newProject: lastTask, showPicker: $showPicker, toggleEditor: self.$projectModel.showEditTaskEditor)

                VStack(alignment: .leading, spacing: 15) {
                    CardTopView(newTask: lastTask, showPicker: $showPicker, showImagePicker: $showImagePicker)
                    
                    if (lastTask.coverImage == nil) {
                        Text("Project Color")
                        ScrollView(.horizontal) {
                            HStack {
                                Circle()
                                    .strokeBorder(.gray, lineWidth: 1)
                                    .background(Circle().fill(Color(ColorPalette.blushPink)))
                                    .frame(width: 35, height: 35)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }

            Button {
                if lastTask != projectModel.taskToEdit {
                    self.projectModel.projectsTasks = self.coreDataModel.addSubtask(to: lastTask.id, subtask: lastTask)
                    if let updatedTask = findTask(in: projectModel.projectsTasks, withID: lastTask.id) {
                        projectModel.changeSelectedTask(task: updatedTask)
                    } else {
                        print("task wasnt found")
                        projectModel.changeSelectedTask(task: projectModel.default_Project)
                    }
                }
            } label: {
                if lastTask != projectModel.taskToEdit {
                    Text("Update Project")
                        .padding()
                        .padding(.horizontal)
                        .foregroundColor(Color("TextColor"))
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color("TextColor"), lineWidth: 1))
                } else {
                    Text("Update Project")
                        .padding()
                        .padding(.horizontal)
                        .foregroundColor(Color.gray)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .foregroundStyle(Color("TextColor"))
        .fullScreenCover(isPresented: self.$showPicker) {
            IconPicker(newProject: lastTask, showPicker: $showPicker)
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
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
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        lastTask.coverImage = inputImage
    }
}
