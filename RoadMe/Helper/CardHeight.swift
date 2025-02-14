//
//  CardHeight.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 07.01.25.
//

import Foundation
import UIKit

struct CardSHeightLookUp {
    static func getCardHeight(for numberOfColumns: Int, deviceType: DeviceType, orientation: UIDeviceOrientation) -> CGFloat {
        switch deviceType {
        case .iPhone:
            return iPhoneCardHeight(for: numberOfColumns, orientation: orientation)
        case .iPad:
            return iPadCardHeight(for: numberOfColumns, orientation: orientation)
        case .Mac:
            return macCardHeight(for: numberOfColumns)
        }
    }
    
    private static func iPhoneCardHeight(for numberOfColumns: Int, orientation: UIDeviceOrientation) -> CGFloat {
        switch numberOfColumns {
        case 1:
            return orientation.isPortrait ? 150 : 150
        case 2:
            return orientation.isPortrait ? 140 : 150
        case 3:
            return orientation.isPortrait ? 130 : 130
        default:
            return orientation.isPortrait ? 150 : 150
        }
    }
    
    private static func iPadCardHeight(for numberOfColumns: Int, orientation: UIDeviceOrientation) -> CGFloat {
        return 170
    }
    
    private static func macCardHeight(for numberOfColumns: Int) -> CGFloat {
        return 170
    }
}
