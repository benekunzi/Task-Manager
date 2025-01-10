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
    
    @State var selectedTab = "house"
   
    let sidebarWidth: CGFloat = UIScreen.main.bounds.width / 1.5
    
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
                
                VStack {
                    Text("Person")
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("BackgroundColor"))
                    .zIndex(1)
                    .tag("person")
            }
            
            TabBarView(selectedTab: $selectedTab)
                .overlay(
                    HStack(alignment: .top) {
                        Spacer()
                        Image("Bee")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .onTapGesture {
                                self.projectModel.showTaskEditor.toggle()
                            }
                        Spacer()
                    }
                        .offset(y: -45)
                )
            
            if (self.projectModel.showNameEditor) {
                CreateProjectView()
                    .zIndex(2)
                    .transition(.move(edge: .bottom))
            }
            if (self.projectModel.showTaskEditor) {
                CreateTaskCardView()
                    .zIndex(2)
                    .transition(.move(edge: .bottom))
            }
            if (self.projectModel.showEditTaskEditor) {
                EditTaskEditor()
                    .zIndex(2)
                    .transition(.move(edge: .bottom))
            }
        }
        .foregroundStyle(Color("TextColor"))
        .preferredColorScheme(.light)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            let mappedProjects = self.coreDataModel.mapToModel()
            self.projectModel.projectsTasks = mappedProjects
            self.projectModel.selectedTask = self.projectModel.default_Project
        }
        .environmentObject(self.projectModel)
        .environmentObject(self.coreDataModel)
        .animation(.linear, value: self.projectModel.showTaskEditor)
        .animation(.linear, value: self.projectModel.showNameEditor)
        .animation(.linear, value: self.projectModel.showEditTaskEditor)
    }
}

#Preview {
    ContentView()
}
