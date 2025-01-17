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
    
    @State private var selectedImage: UIImage?
    @State private var inputImage: UIImage?
    @StateObject var newProject: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "BlushPink",
        isCompleted: false)
    @ObservedObject var themeManager: ThemeManager = ThemeManager()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack() {
                    Image(systemName: "xmark")
                        .font(.system(size: 16).weight(.bold))
                        .padding(5)
                        .foregroundStyle(Color("LightGray"))
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
                        .onTapGesture {projectModel.showProjectEditor = false}
                    
                    Spacer()
                    
                    CreateProjectButtonView(newProject: newProject, themeManager: themeManager)
                }
                .padding(.horizontal)
                .padding(.top)

                VStack(alignment: .leading, spacing: 25) {
                    CardTopView(newTask: newProject)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Themes")
                            .font(.system(size: 20).weight(.bold))
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(themeManager.themes) {theme in
                                    theme.backgroundImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Project Color Palette")
                            .font(.system(size: 20).weight(.bold))
                        ScrollView(.horizontal) {
                            HStack(spacing: 15) {
                                ForEach(themeManager.currentTheme.colorPalette, id:\.self) { c in
                                    Circle()
                                        .strokeBorder(.gray, lineWidth: 1)
                                        .background(Circle().fill(Color(c)))
                                        .frame(width: 35, height: 35)
                                }
                            }
                        }
                    }
                    Text("Project Icons")
                        .font(.system(size: 20).weight(.bold))
                    Spacer()
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .foregroundStyle(Color("TextColor"))
        .onChange(of: inputImage) { _ in loadImage() }
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

struct CreateProjectButtonView: View {
    
    @StateObject var newProject: ProjectTask
    @ObservedObject var themeManager: ThemeManager
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    var body: some View {
        Button {
            if newProject.name != "" {
                let mappedProjects = self.coreDataModel.addRootTask(task: newProject,
                                                                    themeId: self.themeManager.currentTheme.id)
                self.projectModel.toggleUIUpdate()
                self.projectModel.projectsTasks = mappedProjects
                self.projectModel.selectedTask = newProject
                self.projectModel.selectedTheme = self.themeManager.currentTheme
                self.projectModel.showProjectEditor = false
            }
        } label: {
            if newProject.name != "" {
                Text("Create Project")
                    .font(.system(size: 16).weight(.bold))
                    .foregroundColor(Color("LightGray"))
                    .padding(5)
                    .padding(.horizontal, 3)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
            } else {
                Text("Create Project")
                    .font(.system(size: 16).weight(.bold))
                    .foregroundColor(Color.gray)
                    .padding(5)
                    .padding(.horizontal, 3)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("Theme-1-VeryDarkGreen")))
            }
        }
    }
}

#Preview {
    ContentView()
}
