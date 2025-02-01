//
//  ListView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 31.01.25.
//

import SwiftUI
import WebKit

struct ListView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var projectModel: ProjectModel
    
    private let impactMed = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                Button {
                    impactMed.impactOccurred()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first,
                       let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                        applyUnorderedList(webView: webView)
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 20))
                }.buttonStyle(.borderless)
                
                Button {
                    impactMed.impactOccurred()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first,
                       let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                        applyOrderedList(webView: webView)
                    }
                } label: {
                    Image(systemName: "list.number")
                        .font(.system(size: 20))
                }.buttonStyle(.borderless)
                
                Button {
                    impactMed.impactOccurred()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first,
                       let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                        insertCheckbox(webView: webView)
                    }
                } label: {
                    Image(systemName: "checklist")
                        .font(.system(size: 20))
                }.buttonStyle(.borderless)
            }
            .foregroundStyle(
                Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
            )
        }
    }
    
    private func applyOrderedList(webView: WKWebView) {
        let jsCode = "applyOrderedList();"
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }

    private func applyUnorderedList(webView: WKWebView) {
        let jsCode = "applyUnorderedList();"
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }
    
    private func insertCheckbox(webView: WKWebView) {
        let jsCode = "insertCheckbox();"
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }
}
