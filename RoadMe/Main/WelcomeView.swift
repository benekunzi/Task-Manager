//
//  WelcomeView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 26.12.24.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @State var projectTasks: [ProjectTask] = []
    
    let gridColumns: [GridItem] = [GridItem(.flexible())]
    
    @State var showMoreOptions: Bool = false
    @State var isWiggling: Bool = false
    @State var isTapped: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Meine Aufgaben")
                .font(.custom("Inter-Regular_Bold", size: 20))
                .foregroundStyle(Color.black)
                .padding()
            ZStack {
                ScrollView(.vertical) {
                    LazyVGrid(columns: self.gridColumns, alignment: .center, spacing: 20) {
                        ForEach(self.projectTasks) { task in
                            NavigationLink(destination: MainView(task: task)) {
                                WelcomeCardView(task: task, showMoreOptions: $showMoreOptions)
                            }
                            .modifier(WelcomeChunkyButtonModifier(isTap: $isTapped))
                            .padding(.horizontal, 30)
                            .rotationEffect(.degrees(isWiggling ? 2.5 : 0))
                            .rotation3DEffect(.degrees(0), axis: (x: 0, y: -5, z: 0))
                            .animation(
                                isWiggling
                                ? Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true)
                                : .default, // Default stops the animation
                                value: isWiggling
                            )
                        }
                    }
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
                                if (self.projectModel.selectedTask == self.projectModel.default_Project) {
                                    self.projectModel.showProjectEditor.toggle()
                                } else {
                                    self.projectModel.showTaskEditor.toggle()
                                }
                            }
                        Spacer()
                    }
                }
                    .offset(y: -95)
            }
            .padding(.horizontal)
        }.onTapGesture {
            if (showMoreOptions) {
                showMoreOptions.toggle()
            }
        }
        .onChange(of: showMoreOptions) { isWiggling = $0 }
        .onChange(of: projectModel.updateUI) {newValue in
            self.projectTasks = self.projectModel.projectsTasks
        }
        .onAppear {
            self.projectTasks = self.projectModel.projectsTasks
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct WelcomeCardView: View {
    
    @ObservedObject var task: ProjectTask
    @Binding var showMoreOptions: Bool
    
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var projectModel: ProjectModel
    
    var body: some View {
        ZStack() {
            Image("Theme-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()

            // Icon overlay
            if (task.iconImage != nil) {
                VStack {
                    HStack(spacing: 5) {
                        Image(uiImage: task.iconImage!)
                            .resizable()
                            .frame(width: 30, height: 30) // Adjust icon size as needed
                            .background(Color.white) // Add white background for contrast
                            .clipShape(Circle()) // Make it circular if needed
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1)) // Optional border
                            .offset(y: 0) // Move it upwards to overlap both halves
                        
                        Text(task.name)
                            .font(.custom("Inter-Regular_Bold", size: 16))
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.top, 10)
                    Spacer()
                }
            }
            else if (task.iconString != nil) {
                VStack {
                    HStack(spacing: 5) {
                        Text(task.iconString!)
                            .font(.custom("Inter-Regular_Bold", size: 16))
                            .offset(y: 0)
                        Text(task.name)
                            .font(.custom("Inter-Regular_Bold", size: 16))
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.top, 10)
                    Spacer()
                }
            }
            else {
                VStack {
                    HStack {
                        Text(task.name)
                            .font(.custom("Inter-Regular_Bold", size: 16))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 10)
                .padding(.top, 10)
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .frame(height: 150) // Ensure total height
        .overlay(
            TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
        )
//        .padding(.top)
        .onLongPressGesture {
            showMoreOptions.toggle()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
