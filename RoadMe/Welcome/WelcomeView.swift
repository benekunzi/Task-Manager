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
    
    let fontModel: FontModel = FontModel()

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
                    .font(.custom("BowlbyOne-Regular", size: 20))
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
                    .font(.custom("SpaceGrotesk-Regular", size: 16))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
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
    
    @EnvironmentObject var projectModel: ProjectModel
    
    @State private var currentDate = Date()
    @State private var timer: Timer?
    
    private let fontModel: FontModel = FontModel()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back!")
                        .font(.custom(fontModel.font_title, size: 20))
                    Text("\(formattedDate)")
                        .font(.custom(fontModel.font_body_medium, size: 14))
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
                        .font(.custom(fontModel.font_body_bold, size: 18))
                    Text("\(projectModel.taskCounter) of 10 tasks completed today")
                        .font(.custom(fontModel.font_body_semiBold, size: 14))
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
        .onAppear {
            startMidnightTracking()
            projectModel.countTasks(date: .now)
        }
        .onDisappear {
            stopMidnightTracking()
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: currentDate)
    }
    
    private func startMidnightTracking() {
        // Invalidate existing timer if any
        timer?.invalidate()
        
        // Calculate the time until midnight
        let now = Date()
        let calendar = Calendar.current
        if let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) {
            let secondsUntilMidnight = nextMidnight.timeIntervalSince(now)
            print("seconds till midnight: \(secondsUntilMidnight)")
            
            // Start a timer that triggers at midnight
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsUntilMidnight) {
                updateDate()
                projectModel.countTasks(date: self.currentDate)
                // Restart the tracking to ensure continuous midnight checks
                self.startMidnightTracking()
            }
        }
    }
    
    private func updateDate() {
        self.currentDate = Date()
    }
    
    private func stopMidnightTracking() {
        timer?.invalidate()
        timer = nil
    }
}

class AnimationNamespaceWrapper: ObservableObject {
    var namespace: Namespace.ID

    init(_ namespace: Namespace.ID) {
        self.namespace = namespace
    }
}
