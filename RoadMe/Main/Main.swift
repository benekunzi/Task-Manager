//
//  Main.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI

struct MainView: View {
    
    @Binding var offsetWelcomeView: CGFloat
    @Binding var showMainView: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var animationNamespace: AnimationNamespaceWrapper
    @Namespace private var tabAnimationNamespace
    
    @State var navigationTitle: String = ""
    @State var taskDescription: String = ""
    @State var isWiggling: Bool = false
    @State var showMoreOptions: Bool = false
    @State private var cardPositions: [UUID: CGPoint] = [:]
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var numberOfColumns: Int = 1
    @State var scale: CGFloat = 1
    @State private var showMenu: Bool = false
    @State private var showSubtasks: Bool = true
    @State private var selectedIndex: Int = 1
    @State private var selectedTab: Int = 0
    
    private let menuGridSymbols: [String] = [
        "list.bullet",
        "rectangle.grid.1x2",
        "square.grid.2x2",
        "square.grid.3x2"
    ]
    private let tabs: [String] = ["Tasks", "Notes"]
    private let fontModel: FontModel = FontModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                TopView
                    .offset(y: projectModel.offsetTopView)
                    .animation(.spring(), value: projectModel.offsetTopView) // Add animation
                
                if (!projectModel.selectedTask.subtasks.isEmpty) {
                    ScrollView(showsIndicators: false) {
                        Spacer(minLength: 10)
                        MainContentView(showMoreOptions: $showMoreOptions,
                                        isWiggling: $isWiggling,
                                        columns: self.$columns,
                                        numberOfColumns: $numberOfColumns,
                                        showSubtasks: $showSubtasks,
                                        scale: $scale)
                        .onChange(of: projectModel.selectedTask) { newTask in
                            showMoreOptions = false
                            isWiggling = false
                        }
                        .onChange(of: showMoreOptions) { isWiggling = $0 }
                        Spacer(minLength: projectModel.offsetContentBottom)
                    }
                } else {
                    VStack(alignment: .center) {
                        Spacer()
                        Text("Noch keine Aufgaben erstellt")
                            .font(.custom(fontModel.font_body_medium, size: 16))
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    .offset(y: projectModel.offsetTaskCards)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7), // Cascading effect
                        value: projectModel.offsetTaskCards
                    )
                }
            }
            
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 20).weight(.bold))
                            .padding(5)
                            .background(
                                Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                            )
                            .foregroundStyle( Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                            )
                            .clipShape(Circle())
                        Text("New Task")
                            .font(.custom(fontModel.font_body_semiBold, size: 16))
                            .foregroundStyle( Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                            )
                    }
                    .onTapGesture {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        projectModel.showTaskEditor.toggle()
                    }
                    Spacer()
                }
            }
                .offset(y: -95)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all))
        .onTapGesture {
            if (showMoreOptions) {
                showMoreOptions.toggle()
            }
        }
        .onAppear {
            self.navigationTitle = projectModel.selectedTask.name
            self.taskDescription = projectModel.selectedTask.description
            self.projectModel.selectedTheme = projectModel.selectedTask.theme ?? themeBasis
            self.numberOfColumns = Int(coreDataModel.gridSize) == 0 ? 1 : Int(coreDataModel.gridSize)
            self.columns = Array(repeating: GridItem(.flexible()), count: numberOfColumns)
            self.selectedIndex = Int(coreDataModel.gridSize)
            print("number of columns: \(numberOfColumns)")
            if coreDataModel.gridSize == 0 {
                self.showSubtasks = false
            }
        }
        .onChange(of: self.numberOfColumns) { newValue in
            if newValue == 1 {
                self.scale = 1.0
            } else if newValue == 2 {
                self.scale = 0.75
            } else if newValue == 3 {
                self.scale = 0.5
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .id(projectModel.redrawID)
    }
    
    private var TopView: some View {
        VStack(spacing: 4) {
            HStack {
                Button {
                    Task {
                        let currentTask = self.projectModel.selectedTask
                        if let parentId = currentTask.parentTaskId {
                            if let parentTask = findTask(in: self.projectModel.projectsTasks, withID: parentId) {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                projectModel.offsetTaskCards = UIScreen.main.bounds.height
                                
                                try? await Task.sleep(nanoseconds: 200_000_000)
                                
                                self.projectModel.changeSelectedTask(task: parentTask)
                                projectModel.offsetTaskCards = -(UIScreen.main.bounds.height * 2)
                                
                                try? await Task.sleep(nanoseconds: 200_000_000)
                                
                                projectModel.offsetTaskCards = 0
                                
                                self.isWiggling = false
                                self.showMoreOptions = false
                            }
                        } else {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            projectModel.offsetTaskCards = UIScreen.main.bounds.height
                            projectModel.offsetTopView = -(UIScreen.main.bounds.height)
                            
                            try? await Task.sleep(nanoseconds: 200_000_000)
                            
                            offsetWelcomeView = -(UIScreen.main.bounds.height)
                            showMainView.toggle()
                            projectModel.showDetailView.toggle()
                            self.projectModel.selectedProject = nil
                            self.projectModel.changeSelectedTask(task: projectModel.default_Project)
                            
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            
                            offsetWelcomeView = 0
                            
                            print("changing back to default task")
                        }
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16).weight(.bold))
                        .foregroundColor(Color.black)
                }
                Spacer()
                
                HStack(spacing: 8) {
                    Text(navigationTitle)
                        .font(.custom(fontModel.font_title, size: 16))
                        .foregroundColor(Color.black)
                        .onChange(of: self.projectModel.selectedTask) { task in
                            self.navigationTitle = task.name
                        }
                    Image(systemName: showMenu ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16).weight(.bold))
                        .foregroundColor(Color.black)
                }
                .onTapGesture {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    withAnimation(.spring()) {
                        self.showMenu.toggle()
                    }
                }
                Spacer()
            }
            
            if (!taskDescription.isEmpty) {
                Text(taskDescription)
                    .font(.custom(fontModel.font_body_bold, size: 14))
                    .foregroundColor(Color.gray)
                    .onChange(of: self.projectModel.selectedTask) { task in
                        self.taskDescription = task.description
                    }
            }
            if showMenu {
                ScrollView(.horizontal) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("Grid size")
                            .font(.custom(fontModel.font_body_bold, size: 14))
                            .foregroundColor(Color.gray)
                        HStack(spacing: 10) {
                            ForEach(Array(self.menuGridSymbols.enumerated()), id: \.0) { index, symbol in
                                Image(systemName: symbol)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                index == selectedIndex
                                                    ? Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                                                    : Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                                            )
                                    )
                                    .foregroundStyle(
                                        index == selectedIndex
                                            ? Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                                            : Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                                    )
                                    .onTapGesture {
                                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                                        impactMed.impactOccurred()
                                        
                                        withAnimation(.spring()) {
                                            self.selectedIndex = index
                                            
                                            let n = index == 0 ? 1 : index
                                            self.numberOfColumns = n
                                            self.columns = Array(repeating: GridItem(.flexible()), count: n)
                                            print("selected Index: \(index)")
                                            self.coreDataModel.updateGridSize(Int16(index))
                                            
                                            if index == 0 {
                                                self.showSubtasks = false
                                            } else {
                                                self.showSubtasks = true
                                            }
                                        }
                                    }
                            }
                        }
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary),
                            Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                        )
                        .font(.system(size: 16).weight(.bold))
                        .padding(.bottom, 10)
                    }
                }
            }
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(tabs[index])
                            .font(
                                .custom(selectedTab == index
                                        ? fontModel.font_body_bold
                                        : fontModel.font_body_medium, size: 16)
                            )
                            .foregroundColor(selectedTab == index
                                             ? Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                                             : .gray)
                        
                        if selectedTab == index {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                                .matchedGeometryEffect(id: "underline", in: tabAnimationNamespace)
                        } else {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.clear)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedTab = index
                            if index == 0 {
                                projectModel.taskTab = .tasks
                            } else {
                                projectModel.taskTab = .editor
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }.padding(.vertical, 10)
        }
    }
}
