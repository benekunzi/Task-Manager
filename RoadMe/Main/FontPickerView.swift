//
//  FontPickerView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 28.01.25.
//

import SwiftUI
import WebKit

struct FontPickerView: View {
    
    @Binding var showFontSizeSlider: Bool
    @Binding var selectedFont: GhibliFont
    @Binding var selectedFontSize: CGFloat
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var editorModel: EditorModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                Menu {
                    Picker(selection: $selectedFont) {
                        ForEach(GhibliFont.allCases, id: \.self) { font in
                            Text(font.displayName)
                        }
                    } label: {}
                } label: {
                    HStack(spacing: 0) {
                        Text(selectedFont.displayName)
                            .font(.custom(selectedFont.name, size: 18))
                            .foregroundStyle(Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                    }
                }

                .onChange(of: selectedFont) { _ in
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first,
                       let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                        print(editorModel.isTextSelected)
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
                
                HStack(spacing: 0) {
                    Text("\(Int(selectedFontSize))")
                        .font(.custom(selectedFont.name, size: 18))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 16))
                }
                .foregroundStyle(Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary))
                .onTapGesture {
                    withAnimation(.spring() ){
                        self.showFontSizeSlider.toggle()
                    }
                }
                Spacer()
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
