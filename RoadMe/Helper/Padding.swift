//
//  Padding.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 18.01.25.
//

import Foundation
import UIKit

struct PaddingLookUp {
    static func getPadding(for numberOfColumns: Int, deviceType: DeviceType, orientation: UIDeviceOrientation, paddingCorner: PaddingCorner) -> CGFloat {
        switch deviceType {
        case .iPhone:
            return iPhonePadding(for: numberOfColumns, orientation: orientation, paddingCorner: paddingCorner)
        case .iPad:
            return iPadPadding(for: numberOfColumns, orientation: orientation, paddingCorner: paddingCorner)
        case .Mac:
            return macPadding(for: numberOfColumns, orientation: orientation, paddingCorner: paddingCorner)
        }
    }
    
    private static func iPhonePadding(for numberOfColumns: Int, orientation: UIDeviceOrientation, paddingCorner: PaddingCorner) -> CGFloat {
        switch numberOfColumns {
        case 1:
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return paddingCorner == .horizontal ? 20 : 20
            case .landscapeRight, .landscapeLeft:
                return paddingCorner == .horizontal ? 20 : 20
            default:
                return paddingCorner == .horizontal ? 20 : 20
            }
        case 2:
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return paddingCorner == .horizontal ? 14 : 14
            case .landscapeRight, .landscapeLeft:
                return paddingCorner == .horizontal ? 14 : 14
            default:
                return paddingCorner == .horizontal ? 14 : 14
            }
        case 3:
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return paddingCorner == .horizontal ? 8 : 8
            case .landscapeRight, .landscapeLeft:
                return paddingCorner == .horizontal ? 8 : 8
            default:
                return paddingCorner == .horizontal ? 8 : 8
            }
        default:
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return paddingCorner == .horizontal ? 20 : 20
            case .landscapeRight, .landscapeLeft:
                return paddingCorner == .horizontal ? 20 : 20
            default:
                return paddingCorner == .horizontal ? 20 : 20
            }
        }
    }
    
    private static func iPadPadding(for numberOfColumns: Int, orientation: UIDeviceOrientation, paddingCorner: PaddingCorner) -> CGFloat {
        return 20
    }
    
    private static func macPadding(for numberOfColumns: Int, orientation: UIDeviceOrientation, paddingCorner: PaddingCorner) -> CGFloat {
        return 20
    }
}

enum PaddingCorner {
    case top, bottom, leading, trailing, horizontal, vertical
}
