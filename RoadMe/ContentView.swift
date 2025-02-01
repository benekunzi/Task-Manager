//
//  ContentView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 22.12.24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var projectModel: ProjectModel = ProjectModel()
    @ObservedObject var coreDataModel: CoreDataModel = CoreDataModel()
    @ObservedObject var themeManager: ThemeManager = ThemeManager()
    @ObservedObject var editorModel: EditorModel = EditorModel()
    
    @State var selectedTab = "house"
   
    let sidebarWidth: CGFloat = UIScreen.main.bounds.width / 1.5
    private let contentVStackGap: CGFloat = 20/2
    
    init() {
        for familyName in UIFont.familyNames {
            if (familyName == "Inter" ||
                familyName == "Bowlby One" ||
                familyName == "Space Grotesk") {
                for fontName in UIFont.fontNames(forFamilyName: familyName) {
                    print("\(familyName): \(fontName)")
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView(selection: $selectedTab) {
                WelcomeView()
                    .background(Color("BackgroundColor"))
                    .edgesIgnoringSafeArea(.bottom)
                    .zIndex(1)
                    .tag("house")
                
                FocusView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("BackgroundColor"))
                    .zIndex(1)
                    .tag("timer")
                
                Shop()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("BackgroundColor"))
                    .zIndex(1)
                    .tag("cart")
                
                VStack {
                    Text("Person")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("BackgroundColor"))
                .zIndex(1)
                .tag("person")
            }
            
            TabBarView(selectedTab: $selectedTab)
                .readHeight {
                    print("height of tapbar: \($0)")
                    self.projectModel.offsetContentBottom = $0 + contentVStackGap
                }
        }
        .sheet(isPresented: self.$projectModel.showProjectEditor) {
            CreateProjectView()
        }
        .sheet(isPresented: self.$projectModel.showTaskEditor, content: {
            CreateAndUpdateTaskCardView(updateExistingTask: false)
        })
        .sheet(isPresented: self.$projectModel.showEditTaskEditor, content: {
            CreateAndUpdateTaskCardView(updateExistingTask: true)
        })
        .foregroundStyle(Color("TextColor"))
        .preferredColorScheme(.light)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            coreDataModel.fetchTags()
            let mappedProjects = self.coreDataModel.mapToModel()
            self.projectModel.projectsTasks = mappedProjects
            self.projectModel.selectedTask = self.projectModel.default_Project
        }
        .environmentObject(self.projectModel)
        .environmentObject(self.coreDataModel)
        .environmentObject(self.themeManager)
        .environmentObject(self.editorModel)
    }
}

extension View {
  func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Spacer()
          .preference(
            key: HeightPreferenceKey.self,
            value: geometryProxy.size.height
          )
      }
    )
    .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
  }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
