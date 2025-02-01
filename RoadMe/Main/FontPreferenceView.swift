//
//  FontPreferenceView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 28.01.25.
//

import SwiftUI

struct FontPreferenceView: View {
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var editorModel: EditorModel
    @Namespace private var tabAnimationNamespace
    @State private var showFontSizeSlider: Bool = false
    
    private let editorTabs: [EditorTabs] = [.font, .list, .media]
    
    var body: some View {
        HStack(spacing: 10) {
            if (editorModel.editorTab != nil) {
                // Selected tab moves to the left
                VStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: editorModel.editorTab!.systemImageName)
                            .font(.system(size: 20))
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
                            .matchedGeometryEffect(id: editorModel.editorTab, in: tabAnimationNamespace)
                            .onTapGesture {
                                self.editorModel.editorTab = nil
                            }
                        
                        Divider()
                            .frame(height: 20)
                        
                        if editorModel.editorTab == .font {
                            if editorModel.isTextSelected {
                                FontPickerView(showFontSizeSlider: $showFontSizeSlider,
                                               selectedFont: $editorModel.selectedFont,
                                               selectedFontSize: $editorModel.selectedFontSize)
                            } else {
                                FontPickerView(showFontSizeSlider: $showFontSizeSlider,
                                               selectedFont: $editorModel.globalFont,
                                               selectedFontSize: $editorModel.globalFontSize)
                            }
                        } else if editorModel.editorTab == .media {
                            MediaView()
                        } else if editorModel.editorTab == .list {
                            ListView()
                        }
                    }
                    if showFontSizeSlider {
                        if editorModel.isTextSelected {
                            FontSizeSliderView(selectedFontSize: $editorModel.selectedFontSize,
                                               selectedFont: $editorModel.selectedFont)
                        } else {
                            FontSizeSliderView(selectedFontSize: $editorModel.globalFontSize,
                                               selectedFont: $editorModel.selectedFont)
                        }
                    }
                }.padding(.vertical, 8)
            }
            else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(EditorTabs.allCases, id: \.self) { tab in
                            Image(systemName: tab.systemImageName)
                                .font(.system(size: 20))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            tab == editorModel.editorTab
                                            ? Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                                            : Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                                        )
                                )
                                .foregroundStyle(
                                    tab == editorModel.editorTab
                                    ? Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                                    : Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                                )
                                .matchedGeometryEffect(id: tab, in: tabAnimationNamespace)
                                .onTapGesture {
                                    self.editorModel.editorTab = tab
                                }
                        }
                    }
                }
            }
        }.onChange(of: editorModel.editorTab) { newValue in
            print("change")
        }
    }
}
