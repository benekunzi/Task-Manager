//
//  EditorModel.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 28.01.25.
//

import SwiftUI

enum EditorTabs: CaseIterable {
    case font, list, media
    
    // Computed property to return the corresponding system image
    var systemImageName: String {
        switch self {
        case .font:
            return "textformat.alt"
        case .list:
            return "list.triangle"
        case .media:
            return "paperclip"
        }
    }
}

class EditorModel: ObservableObject {
    @Published var globalFont: GhibliFont = .regular
    @Published var globalFontSize: CGFloat = 16
    @Published var selectedFontSize: CGFloat = 16
    @Published var selectedFont: GhibliFont = .regular
    @Published var isTextSelected: Bool = false
    @Published var attributedText = NSMutableAttributedString(string: "")
    @Published var editorTab: EditorTabs?
}
