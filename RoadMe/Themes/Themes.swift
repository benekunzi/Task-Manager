//
//  Themes.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 16.01.25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    @Published var themes: [Theme]
    
    init() {
        let availableThemes: [Theme] = [themeBasis]
        self.themes = availableThemes
        self.currentTheme = availableThemes.first! // Default to the first theme
    }
    
    func selectTheme(_ theme: Theme) {
        currentTheme = theme
    }
}

let themeBasis = Theme(
    colors: [
        "green": ColorSet(primary: "Theme-1-Green-Primary", secondary: "Theme-1-Green-Secondary"),
        "blue": ColorSet(primary: "Theme-1-Blue-Primary", secondary: "Theme-1-Blue-Secondary"),
        "purple": ColorSet(primary: "Theme-1-Purple-Primary", secondary: "Theme-1-Purple-Secondary")
    ],
    icons: [
        "Theme-1-Icon1",
        "Theme-1-Icon2",
        "Theme-1-Icon3"
    ]
)

struct Theme: Identifiable {
    let id = UUID()
    let colors: [String: ColorSet] // Dictionary to map color names to ColorSet
    let icons: [String]
}

struct ColorSet {
    let primary: String
    let secondary: String
}
