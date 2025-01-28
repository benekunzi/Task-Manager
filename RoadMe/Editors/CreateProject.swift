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
    
    private let fontModel: FontModel = FontModel()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack() {
                    Text("Cancel")
                        .font(.custom(fontModel.font_body_medium, size: 16))
                        .foregroundStyle(Color.black)
                        .onTapGesture {projectModel.showProjectEditor = false}
                    
                    Spacer()
                    
                    CreateProjectButtonView(newProject: newProject, themeManager: themeManager)
                }
                .padding(.horizontal)
                .padding(.top)

                VStack(alignment: .leading, spacing: 25) {
                    CardTopView(newTask: newProject)
            
                    TaskColorPicker(selectedColor: $selectedColor)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tag hinzufügen")
                            .font(.custom(fontModel.font_body_medium, size: 18))
                        WrappingHStack(id: \.self, horizontalSpacing: 20, verticalSpacing: 20) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.custom(fontModel.font_body_regular, size: 14))
                                    .foregroundStyle(selectedTag == tag ? Color(themeManager.currentTheme.colors[selectedColor]!.primary) : Color.gray)
                                    .padding(4)
                                    .padding(.horizontal, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedTag == tag ? Color(themeManager.currentTheme.colors[selectedColor]!.secondary) : Color("LightGray"))
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            if self.selectedTag == tag {
                                                self.selectedTag = ""
                                                newProject.tag = ""
                                            } else {
                                                self.selectedTag = tag
                                                newProject.tag = tag
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 20)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        HStack {
                            TextField("Add new tag",
                                      text: $newTag)
                            .font(.custom(fontModel.font_body_regular, size: 14))
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
                                .font(.custom(fontModel.font_body_regular, size: 14))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(themeManager.currentTheme.colors[selectedColor]!.secondary))
                                )
                                .foregroundStyle(Color(themeManager.currentTheme.colors[selectedColor]!.primary))
                            }

                        }
                        .padding(8)
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
    
    private let fontModel: FontModel = FontModel()
    
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
                    .font(.custom(fontModel.font_body_medium, size: 16))
                    .foregroundStyle(Color.black)
            } else {
                Text("Done")
                    .font(.custom(fontModel.font_body_medium, size: 16))
                    .foregroundStyle(Color("Gray"))
            }
        }
    }
}
