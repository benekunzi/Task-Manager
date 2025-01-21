//
//  ChunkyButton.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 18.01.25.
//

import SwiftUI

struct WelcomeChunkyButtonModifier: ViewModifier {
    
    @Binding var isTap: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Background shadow for 3D effect
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color.black))
                        .offset(y: isTap ? 0 : 5)
                        .animation(.easeInOut(duration: 0.1), value: isTap) // Animation for shadow
                    // Foreground button
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.white))
                }
            )
            .offset(y: isTap ? 5 : 0) // Button movement animation
            .animation(.easeInOut(duration: 0.1), value: isTap) // Smooth animation
    }
}

struct ChunkyButtonModifier: ViewModifier {
    
    @Binding var isTap: Bool
    @Binding var color: String
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    // Background shadow for 3D effect
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.black)
                            RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(color).opacity(0.5))
                        })
                        .offset(y: isTap ? 0 : 5)
                        .animation(.easeInOut(duration: 0.1), value: isTap) // Animation for shadow
                    // Foreground button
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(.black, lineWidth: 0)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color(color)))
                }
            )
            .offset(y: isTap ? 5 : 0) // Button movement animation
            .animation(.easeInOut(duration: 0.1), value: isTap) // Smooth animation
    }
}

