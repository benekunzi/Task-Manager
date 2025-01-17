//
//  Modifier.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 13.01.25.
//

import SwiftUI

struct ProcessBorderModifier: ViewModifier {
    var process: Double // Value between 0 and 1
    var color: Color
    var lineWidth: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    // Right Top Corner
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .trim(from: 0.75, to: 0.75 + min(mapProcess(minDomain: 0, maxDomain: 0.5, value: process), 0.25))
                        .glow(fill: Color.red, lineWidth: lineWidth)
                        .rotationEffect(.degrees(0)) // Default orientation

                    // Left Side
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .trim(from: 0.75 - min(mapProcess(minDomain: 0, maxDomain: 0.5, value: process), 0.25), to: 0.75)
                        .glow(fill: Color.red, lineWidth: lineWidth)
                        .rotationEffect(.degrees(0)) // Default orientation

                    // Right Bottom Side
                    if process > 0.5 {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .trim(from: 0 , to: min(mapProcess(minDomain: 0, maxDomain: 0.25, value: process), 0.25))
                            .glow(fill: Color.red, lineWidth: lineWidth)
                            .rotationEffect(.degrees(0)) // Default orientation
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .trim(from: 0.5 - min(mapProcess(minDomain: 0, maxDomain: 0.25, value: process), 0.25) , to: 0.5)
                            .glow(fill: Color.red, lineWidth: lineWidth)
                            .rotationEffect(.degrees(0)) // Default orientation
                    }
                }
            )
    }
}


extension View where Self: Shape {
  func glow(
    fill: some ShapeStyle,
    lineWidth: Double,
    blurRadius: Double = 4.0,
    lineCap: CGLineCap = .round
  ) -> some View {
    self
      .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
      .fill(fill)
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius)
      }
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius / 2)
      }
  }
}

func mapProcess(minDomain:Double, maxDomain:Double, value:Double) -> Double {
    return minDomain + (maxDomain - minDomain) * (value - 0) / (1 - 0)
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
