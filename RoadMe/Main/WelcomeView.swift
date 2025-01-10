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
    
    let gridColumns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var showMoreOptions: Bool = false
    @State var isWiggling: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Meine Aufgaben")
                .font(.title)
                .foregroundStyle(Color.gray)
                .padding()
            ScrollView(.vertical) {
                LazyVGrid(columns: self.gridColumns, alignment: .center) {
                    ForEach(self.projectTasks) { task in
                        NavigationLink(destination: MainView(task: task)) {
                            WelcomeCardView(task: task, showMoreOptions: $showMoreOptions)
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
            VStack(spacing: 0) { // Remove spacing between image and text
                // Top half: Image or color
                if let coverImage = task.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 75)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(task.color))
                        .frame(height: 75)
                }

                // Bottom half: Text
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        Text(task.name)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 5)
            }

            // Icon overlay
            if (task.iconImage != nil) {
                HStack {
                    Image(uiImage: task.iconImage!)
                        .resizable()
                        .frame(width: 30, height: 30) // Adjust icon size as needed
                        .background(Color.white) // Add white background for contrast
                        .clipShape(Circle()) // Make it circular if needed
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1)) // Optional border
                        .offset(y: 0) // Move it upwards to overlap both halves
                    Spacer()
                }.padding(.leading, 5)
            }
            if (task.iconString != nil) {
                HStack {
                    Text(task.iconString!)
                        .font(.system(size: 30))
                        .offset(y: 0)
                    Spacer()
                }.padding(.leading, 5)
            }
            
        }
        .frame(height: 150) // Ensure total height
        .background(Color.white)
        .mask(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .overlay(
            TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
        )
        .padding(.horizontal)
        .padding(.top)
        .onLongPressGesture {
            showMoreOptions.toggle()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
