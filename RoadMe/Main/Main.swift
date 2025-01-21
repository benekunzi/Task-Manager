//
//  Main.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var task: ProjectTask
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State var navigationTitle: String = ""
    @State var isWiggling: Bool = false
    @State var showMoreOptions: Bool = false
    @State private var cardPositions: [UUID: CGPoint] = [:]
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var numberOfColumns: Int = 1
    @State private var projectTasks: [ProjectTask] = []
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                Spacer(minLength: 10)
                MainContentView(showMoreOptions: $showMoreOptions,
                                isWiggling: $isWiggling,
                                columns: self.$columns,
                                numberOfColumns: $numberOfColumns)
                .id(task.id)
                .onChange(of: projectModel.selectedTask) { task in
                    for subs in task.subtasks {
                        print("\(subs.name): \(subs.index)")
                    }
                    showMoreOptions = false
                    isWiggling = false
                }
                .onChange(of: showMoreOptions) { isWiggling = $0 }
            }
            
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 20).weight(.bold))
                            .padding(5)
                            .background(Color(themeManager.currentTheme.colors["green"]!.secondary))
                            .foregroundStyle(Color(themeManager.currentTheme.colors["green"]!.primary))
                            .clipShape(Circle())
                        Text("New Task")
                            .font(.custom("Inter-Regular_SemiBold", size: 16))
                            .foregroundStyle(Color(themeManager.currentTheme.colors["green"]!.primary))
                    }
                    .onTapGesture {
                        if (projectModel.selectedProject == projectModel.default_Project) {
                            projectModel.showProjectEditor.toggle()
                        } else {
                            projectModel.showTaskEditor.toggle()
                        }
                    }
                    Spacer()
                }
            }
                .offset(y: -95)
                .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all))
        .onTapGesture {
            if (showMoreOptions) {
                showMoreOptions.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                if (self.projectModel.selectedTask != projectModel.default_Project) {
                    Button {
                        let currentTask = self.projectModel.selectedTask
                        withAnimation(.spring(duration: 0.25)) {
                            if let parentId = currentTask.parentTaskId {
                                if let parentTask = findTask(in: self.projectTasks, withID: parentId) {
                                    self.projectModel.changeSelectedTask(task: parentTask)
                                    print("\(parentTask.name): \(parentTask.subtasks)")
                                    self.isWiggling = false
                                    self.showMoreOptions = false
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    self.projectModel.changeSelectedTask(task: projectModel.default_Project)
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16).weight(.bold))
                            .foregroundColor(Color.black)
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(navigationTitle)
                    .font(.custom("Inter-Regular_Bold", size: 16))
                    .foregroundColor(Color.black)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button {
#if os(iOS)
                        if (self.numberOfColumns < 3) {
                            self.columns.append(GridItem(.flexible()))
                            self.numberOfColumns += 1
                        }
#endif
                    } label: {
                        Text("Grid verkleinern")
                    }
                    Button {
                        if self.columns.count > 1 {
                            self.columns.remove(at: 0)
                            self.numberOfColumns -= 1
                        }
                    } label: {
                        Text("Grid vergrößern")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16).weight(.bold))
                        .foregroundColor(Color.black)
                }
            }
        }
        .onChange(of: self.projectModel.selectedTask) { task in
            self.navigationTitle = task.name
        }
        .onChange(of: projectModel.updateUI) { _ in
            self.projectTasks = self.projectModel.projectsTasks
        }
        .onAppear {
            self.projectTasks = self.projectModel.projectsTasks
        }
        .onAppear {
            self.projectModel.changeSelectedTask(task: task)
            self.navigationTitle = task.name
            self.projectModel.selectedProject = task
            self.projectModel.selectedTheme = task.theme ?? themeBasis
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
