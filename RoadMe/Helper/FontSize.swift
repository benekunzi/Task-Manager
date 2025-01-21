import Foundation
import UIKit

struct TextSizeLookup {
    static func getFontSize(for numberOfColumns: Int, deviceType: DeviceType, orientation: UIDeviceOrientation, textType: TextType) -> CGFloat {
        switch deviceType {
        case .iPhone:
            return iPhoneFontSize(for: numberOfColumns, orientation: orientation, textType: textType)
        case .iPad:
            return iPadFontSize(for: numberOfColumns, orientation: orientation, textType: textType)
        case .Mac:
            return macFontSize(for: numberOfColumns, textType: textType)
        }
    }
    
    private static func iPhoneFontSize(for columns: Int, orientation: UIDeviceOrientation, textType: TextType) -> CGFloat {
        switch columns {
        case 1:
            switch textType {
            case .name:
                return orientation == .portrait ? 16 : 16
            case .description:
                return orientation == .portrait ? 14 : 14
            case .subtask:
                return orientation == .portrait ? 12 : 12
            case .checkBox:
                return orientation == .portrait ? 22 : 22
            case .subtaskCheckBox:
                return orientation == .portrait ? 14 : 14
            case .infoButton:
                return orientation == .portrait ? 18 : 18
            case .taskCounter:
                return orientation == .portrait ? 12 : 12
            }
        case 2:
            switch textType {
            case .name:
                return orientation == .portrait ? 14 : 14
            case .description:
                return orientation == .portrait ? 12 : 12
            case .subtask:
                return orientation == .portrait ? 10 : 10
            case .checkBox:
                return orientation == .portrait ? 18 : 18
            case .subtaskCheckBox:
                return orientation == .portrait ? 14 : 14
            case .infoButton:
                return orientation == .portrait ? 16: 16
            case .taskCounter:
                return orientation == .portrait ? 10 : 10
            }
        case 3:
            switch textType {
            case .name:
                return orientation == .portrait ? 10 : 10
            case .description:
                return orientation == .portrait ? 8 : 8
            case .subtask:
                return orientation == .portrait ? 6 : 6
            case .checkBox:
                return orientation == .portrait ? 14 : 14
            case .subtaskCheckBox:
                return orientation == .portrait ? 10 : 10
            case .infoButton:
                return orientation == .portrait ? 14 : 14
            case .taskCounter:
                return orientation == .portrait ? 6 : 6
            }
        default:
            switch textType {
            case .name:
                return orientation == .portrait ? 16 : 16
            case .description:
                return orientation == .portrait ? 14 : 14
            case .subtask:
                return orientation == .portrait ? 12 : 12
            case .checkBox:
                return orientation == .portrait ? 22 : 22
            case .subtaskCheckBox:
                return orientation == .portrait ? 16 : 16
            case .infoButton:
                return orientation == .portrait ? 18 : 18
            case .taskCounter:
                return orientation == .portrait ? 12 : 12
            }
        }
    }
    
    private static func iPadFontSize(for columns: Int, orientation: UIDeviceOrientation, textType: TextType) -> CGFloat {
        switch columns {
        case 1:
            switch textType {
            case .name:
                return orientation == .portrait ? 16 : 16
            case .description:
                return orientation == .portrait ? 14 : 14
            case .subtask:
                return orientation == .portrait ? 12 : 12
            case .checkBox:
                return orientation == .portrait ? 22 : 22
            case .subtaskCheckBox:
                return orientation == .portrait ? 16 : 16
            case .infoButton:
                return orientation == .portrait ? 18 : 18
            case .taskCounter:
                return orientation == .portrait ? 12 : 12
            }
        case 2:
            switch textType {
            case .name:
                return orientation == .portrait ? 16 : 16
            case .description:
                return orientation == .portrait ? 14 : 14
            case .subtask:
                return orientation == .portrait ? 12 : 12
            case .checkBox:
                return orientation == .portrait ? 22 : 22
            case .subtaskCheckBox:
                return orientation == .portrait ? 16 : 16
            case .infoButton:
                return orientation == .portrait ? 18 : 18
            case .taskCounter:
                return orientation == .portrait ? 12 : 12
            }
        case 3:
            switch textType {
            case .name:
                return orientation == .portrait ? 16 : 16
            case .description:
                return orientation == .portrait ? 14 : 14
            case .subtask:
                return orientation == .portrait ? 12 : 12
            case .checkBox:
                return orientation == .portrait ? 22 : 22
            case .subtaskCheckBox:
                return orientation == .portrait ? 16 : 16
            case .infoButton:
                return orientation == .portrait ? 18 : 18
            case .taskCounter:
                return orientation == .portrait ? 12 : 12
            }
        default:
            switch textType {
            case .name:
                return orientation == .portrait ? 18 : 16
            case .description:
                return orientation == .portrait ? 12 : 10
            case .subtask:
                return orientation == .portrait ? 8 : 6
            case .checkBox:
                return orientation == .portrait ? 12 : 10
            case .subtaskCheckBox:
                return orientation == .portrait ? 12 : 10
            case .infoButton:
                return orientation == .portrait ? 12 : 10
            case .taskCounter:
                return orientation == .portrait ? 12 : 10
            }
        }
    }
    
    private static func macFontSize(for columns: Int, textType: TextType) -> CGFloat {
        switch columns {
        case 1:
            switch textType {
            case .name:
                return 28
            case .description:
                return 20
            case .subtask:
                return 14
            case .checkBox:
                return 12
            case .subtaskCheckBox:
                return 12
            case .infoButton:
                return 12
            case .taskCounter:
                return 12
            }
        case 2:
            switch textType {
            case .name:
                return 26
            case .description:
                return 18
            case .subtask:
                return 12
            case .checkBox:
                return 12
            case .subtaskCheckBox:
                return 12
            case .infoButton:
                return 12
            case .taskCounter:
                return 12
            }
        case 3:
            switch textType {
            case .name:
                return 24
            case .description:
                return 16
            case .subtask:
                return 10
            case .checkBox:
                return 12
            case .subtaskCheckBox:
                return 12
            case .infoButton:
                return 12
            case .taskCounter:
                return 12
            }
        default:
            switch textType {
            case .name:
                return 22
            case .description:
                return 14
            case .subtask:
                return 10
            case .checkBox:
                return 12
            case .subtaskCheckBox:
                return 12
            case .infoButton:
                return 12
            case .taskCounter:
                return 12
            }
        }
    }
}

enum DeviceType {
    case iPhone, iPad, Mac
}

enum TextType {
    case name, description, subtask, checkBox, subtaskCheckBox, infoButton, taskCounter
}
