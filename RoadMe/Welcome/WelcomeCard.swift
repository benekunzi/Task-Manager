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
    
    @EnvironmentObject var coreDataModel: CoreDataModel
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var themeManager: ThemeManager
    
    private let cardHeight: CGFloat = 80
    
    var body: some View {
        ZStack() {
            Color.white
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(task.name)
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
        )
//        .padding(.top)
        .onLongPressGesture {
            showMoreOptions.toggle()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
