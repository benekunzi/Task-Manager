//
//  Tabbar.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 06.01.25.
//

import Foundation
import SwiftUI

var Tabs = ["house", "timer", "cart", "person"]
var tabNames = [
    "house": "Home",
    "timer": "Focus",
    "cart": "Shop",
    "person": "Profile"
]

struct TabBarView: View {
    
    @Binding var selectedTab: String
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(Tabs, id: \.self) { tab in
                
                TabBarImageView(selectedTab: self.$selectedTab,
                                tab: tab)
                .frame(maxWidth: .infinity)
                
                if tab != Tabs.last {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .padding(.bottom, self.bottomPadding)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color("LightGray"), radius: 1, x: 0, y: -1)
        )
    }
    
    private var bottomPadding: CGFloat {
        // Get the bottom safe area inset
        let bottomSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

        // If there is a bottom safe area inset, return it as the padding
        // Otherwise, return a default padding (e.g., 20 points)
        return bottomSafeAreaInset > 0 ? bottomSafeAreaInset : 20
    }
}

struct TabBarImageView : View {
    @Binding var selectedTab: String
    var tab: String
    
    @State var didUpdateOnStartUp: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: tab)
                .resizable ()
                .renderingMode(.template)
                .font(.system(.body).weight(.bold))
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(selectedTab == tab ? Color.black : Color("Gray"))
                .onTapGesture {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    withAnimation(.spring()) {
                        self.selectedTab = tab
                    }
                }
            
            Text(tabNames[tab]!)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(selectedTab == tab ? Color.black : Color("Gray"))
        }
    }
}


struct CustomShape: Shape {
    
    var xAxis: CGFloat = UIScreen.main.bounds.width / 2
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

            let center = xAxis

            path.move(to: CGPoint(x: center - 50, y: 0))
            let to1 = CGPoint(x: center, y: 35)
            let control1 = CGPoint(x: center - 25, y: 0)
            let control2 = CGPoint(x: center - 25, y: 35)

            let to2 = CGPoint(x: center + 50, y: 0)
            let control3 = CGPoint(x: center + 25, y: 35)
            let control4 = CGPoint(x: center + 25, y: 0)

            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
