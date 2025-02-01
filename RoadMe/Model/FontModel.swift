//
//  FontModel.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 27.01.25.
//

enum GhibliFont: String, CaseIterable {
    case light = "SpaceGrotesk-Light"
    case regular = "SpaceGrotesk-Regular"
    case medium = "SpaceGrotesk-Medium"
    case semiBold = "SpaceGrotesk-SemiBold"
    case bold = "SpaceGrotesk-Bold"
    case title = "BowlbyOne-Regular"

    var name: String {
        return self.rawValue
    }
    
    var displayName: String {
       switch self {
       case .light: return "Light"
       case .regular: return "Regular"
       case .medium: return "Medium"
       case .semiBold: return "Semi-Bold"
       case .bold: return "Bold"
       case .title: return "Title"
       }
   }
}
