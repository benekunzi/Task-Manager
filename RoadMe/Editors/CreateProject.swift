//
//  ProjectName.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI
import WrappingStack

struct CreateProjectView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject var newProject: ProjectTask = ProjectTask(
        id: UUID(),
        name: "",
        description: "",
        subtasks: [],
        color: "",
        isCompleted: false)
    @State var selectedColor: String = "green"
    @State var selectedTag: String = ""
    @State var newTag: String = ""
    @State var tags: [String] = []
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack() {
                    Text("Cancel")
                        .font(.custom("Inter-Regular_Medium", size: 16))
                        .foregroundStyle(Color.black)
                        .onTapGesture {projectModel.showProjectEditor = false}
                    
                    Spacer()
                    
                    CreateProjectButtonView(newProject: newProject, themeManager: themeManager)
                }
                .padding(.horizontal)
                .padding(.top)

                VStack(alignment: .leading, spacing: 25) {
                    CardTopView(newTask: newProject)
            
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Main Project Color")
                            .font(.custom("Inter-Regular_Medium", size: 18))
                            .foregroundStyle(Color.black)
//                            .foregroundStyle(newProject.color == "" ? Color.black : Color(themeManager.currentTheme.colors[selectedColor]!.primary))
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
                                        self.selectedColor = "green"
                                    }
                                Circle()
                                    .strokeBorder(.gray, lineWidth: 1)
                                    .background(Circle().fill(Color(blue)))
                                    .frame(width: 35, height: 35)
                                    .onTapGesture {
                                        self.selectedColor = "blue"
                                    }
                                Circle()
                                    .strokeBorder(.gray, lineWidth: 1)
                                    .background(Circle().fill(Color(purple)))
                                    .frame(width: 35, height: 35)
                                    .onTapGesture {
                                        self.selectedColor = "purple"
                                    }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tag hinzufügen")
                            .font(.custom("Inter-Regular_Medium", size: 18))
                        WrappingHStack(id: \.self, horizontalSpacing: 20, verticalSpacing: 20) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.custom("Inter-Regular_SemiBold", size: 16))
                                    .foregroundStyle(selectedTag == tag ? Color(themeManager.currentTheme.colors[selectedColor]!.primary) : Color("LightGray"))
                                    .padding(4)
                                    .padding(.horizontal, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedTag == tag ? Color(themeManager.currentTheme.colors[selectedColor]!.secondary) : Color("Gray"))
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            if self.selectedTag == tag {
                                                self.selectedTag = ""
                                            } else {
                                                self.selectedTag = tag
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 20)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        HStack {
                            TextField("Add new tag",
                                      text: $newTag)
                            .font(.custom("Inter-Regular_Medium", size: 16))
                            .foregroundStyle(Color.black)
                            .autocorrectionDisabled()
                            
                            Button {
                                if !newTag.isEmpty {
                                    var currentTags = self.tags
                                    currentTags.append(newTag)
                                    print(currentTags)
                                    let status = self.coreDataModel.saveTags(tags: currentTags)
                                    if (status) {
                                        self.tags.append(newTag)
                                        self.newTag = ""
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Add Tag")
                                }
                                .font(.custom("Inter-Regular", size: 16))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(themeManager.currentTheme.colors[selectedColor]!.secondary))
                                )
                                .foregroundStyle(Color(themeManager.currentTheme.colors[selectedColor]!.primary))
                            }

                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .foregroundStyle(Color("TextColor"))
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            self.selectedColor = "green"
            newProject.color = "green"
            self.tags = self.coreDataModel.tags
        }
        .onChange(of: self.selectedColor) { newValue in
            newProject.color = newValue
        }
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
                newProject.parentTaskId = nil
                let mappedProjects = self.coreDataModel.addRootTask(task: newProject,
                                                                    themeId: themeManager.currentTheme.id)
                self.projectModel.toggleUIUpdate()
                self.projectModel.projectsTasks = mappedProjects
                self.projectModel.showProjectEditor = false
            }
        } label: {
            if newProject.name != "" {
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

#Preview {
    ContentView()
}
