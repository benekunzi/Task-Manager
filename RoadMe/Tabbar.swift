//
//  Tabbar.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 06.01.25.
//

import Foundation
import SwiftUI

var Tabs = ["house", "person"]

struct TabBarView: View {
    
    @Binding var selectedTab: String
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(Tabs, id: \.self) { tab in
                
                TabBarImageView(selectedTab: self.$selectedTab,
                                tab: tab)
                .frame(width: 25, height: 25)
                .padding(.horizontal, 30)
                
                if tab != Tabs.last {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .padding(.bottom, self.bottomPadding)
        .background(Color.white.clipShape(CustomShape()).cornerRadius(12))
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
        Image(systemName: tab + ".fill")
            .resizable ()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .foregroundColor(selectedTab == tab ? Color("BackgroundColor") : Color.gray)
//            .padding(selectedTab == tab ? 15 : 0)
//            .background(Color.white.opacity(selectedTab == tab ? 1 : 0).clipShape(Circle()))
//            .offset(x: geo.frame(in: .global).minX - geo.frame(in: .global).midX,
//                    y: selectedTab == tab  ? -45 : 0)
            .onTapGesture {
                withAnimation(.spring()) {
                    self.selectedTab = tab
                }
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
