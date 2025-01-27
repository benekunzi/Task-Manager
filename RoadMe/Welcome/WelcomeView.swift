//
//  WelcomeView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 26.12.24.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @Namespace private var pageLoadingAnimation
    
    @State var showMoreOptions: Bool = false
    @State var isWiggling: Bool = false
    @State var offsetWelcomeView: CGFloat = 0
    @State private var showMainView: Bool = false

    var body: some View {
        ZStack {
            if showMainView {
                MainView(offsetWelcomeView: $offsetWelcomeView,
                         showMainView: $showMainView)
                    .allowsHitTesting(projectModel.showDetailView)
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 32) {
                        
                        WelcomeViewTopContent()
                        
                        WelcomeViewMainContent(showMoreOptions: $showMoreOptions,
                                               isWiggling: $isWiggling,
                                               offsetWelcomeView: $offsetWelcomeView)
                    }
                }
                .background(Color("BackgroundColor"))
                .onTapGesture {
                    if (showMoreOptions) {
                        showMoreOptions.toggle()
                    }
                }
                .allowsHitTesting(!projectModel.showDetailView)
                .offset(y: offsetWelcomeView)
                .animation(.spring(duration: 0.5), value: offsetWelcomeView) // Add animation
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .onChange(of: showMoreOptions) { isWiggling = $0 }
        .onChange(of: projectModel.showDetailView) { state in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.showMainView = state
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(AnimationNamespaceWrapper(pageLoadingAnimation))
    }
}

struct WelcomeViewMainContent: View {
    
    @Binding var showMoreOptions: Bool
    @Binding var isWiggling: Bool
    @Binding var offsetWelcomeView: CGFloat
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var animationNamespace: AnimationNamespaceWrapper
    
    let gridColumns: [GridItem] = [GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                Text("My Projects")
                    .font(.custom("Inter-Regular_Bold", size: 20))
                    .foregroundStyle(Color.black)
                Spacer()
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    self.projectModel.showProjectEditor.toggle()
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
                    WelcomeCardView(task: task,
                                    showMoreOptions: $showMoreOptions,
                                    offsetWelcomeView: $offsetWelcomeView)
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

struct WelcomeViewTopContent: View {
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    var body: some View {
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
    }
}

class AnimationNamespaceWrapper: ObservableObject {
    var namespace: Namespace.ID

    init(_ namespace: Namespace.ID) {
        self.namespace = namespace
    }
}
