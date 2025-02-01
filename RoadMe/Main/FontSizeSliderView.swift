//
//  FontSizeSliderView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 28.01.25.
//

import SwiftUI
import WebKit

struct FontSizeSliderView: View {
    
    @Binding var selectedFontSize: CGFloat
    @Binding var selectedFont: GhibliFont
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var editorModel: EditorModel
    
    var body: some View {
        HStack {
            Text("\(Int(selectedFontSize))pt")
                .font(.custom(GhibliFont.medium.name, size: 14))
                .foregroundStyle(Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
            Slider(value: $selectedFontSize, in: 1...200, step: 1)
                .tint(Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
            Image(systemName: "minus")
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(
                            Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                        )
                )
                .foregroundStyle(
                    Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                )
                .onTapGesture {
                    selectedFontSize -= 1
                }
            Image(systemName: "plus")
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(
                            Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                        )
                )
                .foregroundStyle(
                    Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                )
                .onTapGesture {
                    selectedFontSize += 1
                }
        }
        .onChange(of: selectedFontSize) { _ in
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                if editorModel.isTextSelected {
                    // Apply font only to selected text
                    changeSelectedTextFont(to: editorModel.selectedFont.name, fontSize: editorModel.selectedFontSize, webView: webView)
                } else {
                    // Apply font globally
                    changeEditorFont(to: editorModel.globalFont.name, fontSize: editorModel.globalFontSize, webView: webView)
                }
            } else {
                print("no webview found")
            }
        }
    }
    
    private func changeEditorFont(to fontName: String, fontSize: CGFloat, webView: WKWebView) {
        let jsCode = "changeGlobalFont('\(fontName)', \(fontSize));"
        print(jsCode)
        webView.evaluateJavaScript(jsCode) {(result, error) in
            if error == nil {
                print(result as Any)
            } else {
                print(error as Any)
            }
        }
    }
    
    private func changeSelectedTextFont(to fontName: String, fontSize: CGFloat, webView: WKWebView) {
        let jsCode = "changeSelectedTextFont('\(fontName)', \(fontSize));"
        print(jsCode)
        webView.evaluateJavaScript(jsCode) {(result, error) in
            if error == nil {
                print(result as Any)
            } else {
                print(error as Any)
            }
        }
    }
}
