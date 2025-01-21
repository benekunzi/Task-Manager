//
//  WelcomeView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 26.12.24.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    
    let gridColumns: [GridItem] = [GridItem(.flexible())]
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    @State var showMoreOptions: Bool = false
    @State var isWiggling: Bool = false
    @State var isTapped: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                ScrollView(.vertical) {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome Back!")
                                        .font(.custom("Inter-Regular_Bold", size: 20))
                                    Text(self.dateFormatter.string(from: Date()))
                                        .font(.custom("Inter-Regular_SemiBold", size: 14))
                                        .foregroundStyle(Color("Gray"))
                                }
                                Spacer()
                            }
                            
                            HStack(alignment: .center) {
                                Circle()
                                    .stroke(Color("LightGray"), lineWidth: 3)
                                    .frame(height: 60)
                                    .padding(.horizontal)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Great Progress!")
                                        .font(.custom("Inter-Regular_Bold", size: 18))
                                    Text("6 of 10 tasks completed today")
                                        .font(.custom("Inter-Regular_SemiBold", size: 14))
                                        .foregroundStyle(Color("Gray"))
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100, alignment: .top)
                            .padding(.vertical)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(color: Color("LightGray"), radius: 2, x: 0, y: 2)
                            )
                        }
                        VStack(spacing: 24) {
                            HStack(alignment: .center) {
                                Text("My Projects")
                                    .font(.custom("Inter-Regular_Bold", size: 20))
                                    .foregroundStyle(Color.black)
                                Spacer()
                                Button {
                                    if (self.projectModel.selectedTask == self.projectModel.default_Project) {
                                        self.projectModel.showProjectEditor.toggle()
                                    } else {
                                        self.projectModel.showTaskEditor.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Add Project")
                                    }
                                    .font(.custom("Inter-Regular", size: 16))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.black)
                                    )
                                    .foregroundStyle(Color.white)
                                }.buttonStyle(.borderless)
                                
                            }
                            
                            LazyVGrid(columns: self.gridColumns, alignment: .center, spacing: 16) {
                                ForEach(self.projectModel.projectsTasks) { task in
                                    NavigationLink(destination: MainView(task: task)) {
                                        WelcomeCardView(task: task, showMoreOptions: $showMoreOptions)
                                    }
                                    //                            .modifier(WelcomeChunkyButtonModifier(isTap: $isTapped))
                                    .rotationEffect(.degrees(isWiggling ? 2.5 : 0))
                                    .rotation3DEffect(.degrees(0), axis: (x: 0, y: -5, z: 0))
                                    .animation(
                                        isWiggling
                                        ? Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true)
                                        : .default, // Default stops the animation
                                        value: isWiggling
                                    )
                                }
                            }.id(projectModel.redrawID)
                        }
                    }
                }
//                VStack {
//                    Spacer()
//                    HStack {
//                        Image(systemName: "plus")
//                            .font(.system(size: 20).weight(.bold))
//                            .padding(5)
//                            .background(Color("Theme-1-VeryDarkGreen"))
//                            .foregroundStyle(Color.white)
//                            .clipShape(Circle())
//                            .onTapGesture {
//                                if (self.projectModel.selectedTask == self.projectModel.default_Project) {
//                                    self.projectModel.showProjectEditor.toggle()
//                                } else {
//                                    self.projectModel.showTaskEditor.toggle()
//                                }
//                            }
//                        Spacer()
//                    }
//                }
//                    .offset(y: -95)
            }
            .padding(.horizontal)
            .padding(.top)
        }.onTapGesture {
            if (showMoreOptions) {
                showMoreOptions.toggle()
            }
        }
        .onChange(of: showMoreOptions) { isWiggling = $0 }
        .edgesIgnoringSafeArea(.bottom)
    }
}
