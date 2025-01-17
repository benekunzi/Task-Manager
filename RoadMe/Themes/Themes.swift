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
        let availableThemes: [Theme] = [themeMountain]
        self.themes = availableThemes
        self.currentTheme = availableThemes.first! // Default to the first theme
    }
    
    func selectTheme(_ theme: Theme) {
        currentTheme = theme
    }
}

let themeMountain = Theme (
    backgroundImage: Image("Theme-1"),
    colorPalette: [
        "Theme-1-Green",
        "Theme-1-GreenGray",
        "Theme-1-LightGreenGray",
        "Theme-1-Orange",
        "Theme-1-VeryDarkGreen"
    ],
    icons: [
        "Theme-1-Icon1",
        "Theme-1-Icon2",
        "Theme-1-Icon3"
    ]
)

struct Theme: Identifiable {
    let id = UUID() // Makes it Identifiable
    let backgroundImage: Image
    let colorPalette: [String]
    let icons: [String]
}
