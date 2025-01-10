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
        VStack {
            ScrollView(showsIndicators: false) {
                Spacer(minLength: 10)
                ZStack {
                    // Draw connecting line if there are multiple cards
//                    if (projectModel.selectedTask.subtasks.count > 1 && !showMoreOptions)  {
//                        ConnectingLines(positions: cardPositions)
//                    }
                    MainContentView(showMoreOptions: $showMoreOptions,
                                    isWiggling: $isWiggling,
                                    columns: self.$columns,
                                    numberOfColumns: $numberOfColumns)
                    .id(task.id)
                    
                }
                .onChange(of: projectModel.selectedTask) { task in
                    for subs in task.subtasks {
                        print("\(subs.name): \(subs.index)")
                    }
                    showMoreOptions = false
                    isWiggling = false
                }
                .onChange(of: showMoreOptions) { isWiggling = $0 }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color("BackgroundColor"))
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
                                self.projectModel.changeSelectedTask(task: projectModel.default_Project)
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(Font.body.bold())
                            .foregroundColor(Color.gray)
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(navigationTitle)
                    .font(Font.body.bold())
                    .foregroundColor(Color.gray)
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
                        .font(Font.body.bold())
                        .foregroundColor(Color.gray)
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
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
