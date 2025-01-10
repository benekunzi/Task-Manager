//
//  ProjectName.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI

struct CreateProjectView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @State private var showPicker: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var inputImage: UIImage?
    @StateObject var newProject: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "BlushPink",
        isCompleted: false)
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                TopImageView(newProject: newProject, showPicker: $showPicker, toggleEditor: self.$projectModel.showNameEditor)

                VStack(alignment: .leading, spacing: 15) {
                    CardTopView(newTask: newProject, showPicker: $showPicker, showImagePicker: $showImagePicker)
                    
                    if (newProject.coverImage == nil) {
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
                if newProject.name != "" {
                    let mappedProjects = self.coreDataModel.addRootTask(task: newProject)
                    self.projectModel.toggleUIUpdate()
                    self.projectModel.projectsTasks = mappedProjects
                    self.projectModel.selectedTask = newProject
                    self.projectModel.showNameEditor = false
                }
            } label: {
                if newProject.name != "" {
                    Text("Create Project")
                        .padding()
                        .padding(.horizontal)
                        .foregroundColor(Color("TextColor"))
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color("TextColor"), lineWidth: 1))
                } else {
                    Text("Create Project")
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
            IconPicker(newProject: newProject, showPicker: $showPicker)
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        newProject.coverImage = inputImage
    }
}

func getSafeAreaTop()->CGFloat{
    let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    
    return (keyWindow?.safeAreaInsets.top) ?? 0.0
}

struct TopImageView: View {
    @StateObject var newProject: ProjectTask
    @Binding var showPicker: Bool
    @Binding var toggleEditor: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    
    var body: some View {
        VStack {
            if (newProject.coverImage == nil) {
                Color(newProject.color)
            } else {
                Image(uiImage: newProject.coverImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(height: 175)
        .clipped()
        .overlay {
            VStack {
                HStack() {
                    if (newProject.coverImage != nil) {
                        Text("Entfernen")
                            .foregroundStyle(Color.blue)
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.3)))
                            .onTapGesture {
                                newProject.coverImage = nil
                            }
                    }
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.headline)
                        .padding(3)
                        .background(Circle().fill(Color("BackgroundColor")))
                        .onTapGesture {toggleEditor = false}
                }.padding(.trailing)
                Spacer()
            }.padding(.top, getSafeAreaTop())
        }
        .overlay {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    if (newProject.iconString != nil) {
                        Text(newProject.iconString!)
                            .font(.system(size: 50))
                            .onTapGesture {
                                self.showPicker = true
                            }
                    }
                    else if (newProject.iconImage != nil) {
                        Image(uiImage: newProject.iconImage!)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .mask(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                self.showPicker = true
                            }
                    }
                }
                Spacer()
            }.padding(.leading)
        }
    }
}

#Preview {
    ContentView()
}
