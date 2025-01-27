//
//  WelcomeCard.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 18.01.25.
//

import SwiftUI

struct WelcomeCardView: View {
    
    @ObservedObject var task: ProjectTask
    @Binding var showMoreOptions: Bool
    @Binding var offsetWelcomeView: CGFloat
    
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var animationNamespace: AnimationNamespaceWrapper
    
    private let cardHeight: CGFloat = 80
    
    var body: some View {
        ZStack() {
            Color.white
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(task.name)
//                            .matchedGeometryEffect(id: "ProjectTitle", in: animationNamespace.namespace)
                            .font(.custom("Inter-Regular_Bold", size: 16))
                            .foregroundStyle(Color.black)
                        if task.description != "" {
                            Text(task.description)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundStyle(Color("Gray"))
                        }
                    }
                    Spacer()
                    
                    Text("Private")
                        .padding(4)
                        .padding(.horizontal, 2)
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundStyle(Color(themeManager.currentTheme.colors[task.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                        .background(Capsule().fill(Color(themeManager.currentTheme.colors[task.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)))
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color("LightGray"), radius: 2, x: 0, y: 2)
        )
        .frame(height: self.cardHeight) // Ensure total height
        .overlay(
            TaskOptionOverlayView(showMoreOptions: $showMoreOptions, task: task)
                .padding(.leading, 8)
        )
        .onTapGesture(count: 1) {
            Task {
                print("Tap Gesture. \(Date().timeIntervalSince1970)")
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                self.projectModel.changeSelectedTask(task: task)
                self.projectModel.selectedProject = task
                projectModel.showDetailView.toggle()
                
                try? await Task.sleep(nanoseconds: 150_000_000)
                
                if (!showMoreOptions) {
                    withAnimation(.spring()) {
                        self.offsetWelcomeView = -UIScreen.main.bounds.height
                    }
                } else {
                    showMoreOptions = false
                }
                
                projectModel.offsetTaskCards = UIScreen.main.bounds.height
                projectModel.offsetTopView = -UIScreen.main.bounds.height
                
                try? await Task.sleep(nanoseconds: 150_000_000)
                projectModel.offsetTopView = 0
                
                try? await Task.sleep(nanoseconds: 100_000_000)
                projectModel.offsetTaskCards = 0
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded() { value in
                    print("LongPressGesture started. \(Date().timeIntervalSince1970)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                        impactMed.impactOccurred()
                        if (!showMoreOptions) {
                            showMoreOptions = true
                        }
                    })
                }
                .sequenced(before:TapGesture(count: 1)
                    .onEnded {
                        print("LongPressGesture ended. \(Date().timeIntervalSince1970)")
                    }
                )
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}
