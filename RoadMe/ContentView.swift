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
    
    init() {
        for familyName in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("\(familyName): \(fontName)")
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
//                .overlay(
//                    HStack(alignment: .top) {
//                        Spacer()
//                        Image("Bee")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 50, height: 50)
//                            .onTapGesture {
//                                if self.projectModel.selectedTask == projectModel.default_Project {
//                                    projectModel.showNameEditor.toggle()
//                                } else {
//                                    self.projectModel.showTaskEditor.toggle()
//                                }
//                            }
//                        Spacer()
//                    }
//                        .offset(y: -45)
//                )
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
            let mappedProjects = self.coreDataModel.mapToModel()
            self.projectModel.projectsTasks = mappedProjects
            self.projectModel.selectedTask = self.projectModel.default_Project
        }
        .environmentObject(self.projectModel)
        .environmentObject(self.coreDataModel)
        .animation(.linear, value: self.projectModel.showTaskEditor)
        .animation(.linear, value: self.projectModel.showProjectEditor)
        .animation(.linear, value: self.projectModel.showEditTaskEditor)
    }
}

#Preview {
    ContentView()
}
