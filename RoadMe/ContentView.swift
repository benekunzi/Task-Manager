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
    
    @State var selectedTab = "house"
   
    let sidebarWidth: CGFloat = UIScreen.main.bounds.width / 1.5
    
    init() {
        for familyName in UIFont.familyNames {
            if familyName == "Inter" {
                for fontName in UIFont.fontNames(forFamilyName: familyName) {
                    print("\(familyName): \(fontName)")
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    WelcomeView()
                        .background(Color("BackgroundColor"))
                        
                }
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(1)
                .tag("house")
                
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
        }
        .sheet(isPresented: self.$projectModel.showProjectEditor) {
            CreateProjectView()
        }
        .sheet(isPresented: self.$projectModel.showTaskEditor, content: {
            CreateTaskCardView()
        })
        .sheet(isPresented: self.$projectModel.showEditTaskEditor, content: {
            EditTaskEditor()
        })
        .foregroundStyle(Color("TextColor"))
        .preferredColorScheme(.light)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            _ = coreDataModel.fetchTags()
            let mappedProjects = self.coreDataModel.mapToModel()
            self.projectModel.projectsTasks = mappedProjects
            self.projectModel.selectedTask = self.projectModel.default_Project
        }
        .environmentObject(self.projectModel)
        .environmentObject(self.coreDataModel)
        .environmentObject(self.themeManager)
        .animation(.linear, value: self.projectModel.showTaskEditor)
        .animation(.linear, value: self.projectModel.showProjectEditor)
        .animation(.linear, value: self.projectModel.showEditTaskEditor)
    }
}

#Preview {
    ContentView()
}
