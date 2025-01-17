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
    
    @State var navigationTitle: String = ""
    @State var isWiggling: Bool = false
    @State var showMoreOptions: Bool = false
    @State private var cardPositions: [UUID: CGPoint] = [:]
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var numberOfColumns: Int = 1
    
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
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 20).weight(.bold))
                        .padding(5)
                        .background(Color("Theme-1-VeryDarkGreen"))
                        .foregroundStyle(Color.white)
                        .clipShape(Circle())
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
            Image("Theme-1")
            .resizable()
            .aspectRatio(contentMode: .fill)
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
                                if let parentTask = findTask(in: projectModel.projectsTasks, withID: parentId) {
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
                            .font(.system(.body).weight(.bold))
                            .foregroundColor(Color.black)
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(navigationTitle)
                    .font(.system(.body).weight(.bold))
                    .foregroundColor(Color.black)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button {
                        self.columns.append(GridItem(.flexible()))
                        self.numberOfColumns += 1
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
                        .font(.system(.body).weight(.bold))
                        .foregroundColor(Color.black)
                }
            }
        }
        .onChange(of: self.projectModel.selectedTask) { task in
            self.navigationTitle = task.name
        }
        .onAppear {
            self.projectModel.changeSelectedTask(task: task)
            self.navigationTitle = task.name
            self.projectModel.selectedProject = task
            self.projectModel.selectedTheme = task.theme ?? themeMountain
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
