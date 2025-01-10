import Foundation

struct TextSizeLookup {
    static func getFontSize(for numberOfColumns: Int, deviceType: DeviceType, orientation: Orientation, textType: TextType) -> CGFloat {
        switch deviceType {
        case .iPhone:
            return iPhoneFontSize(for: numberOfColumns, orientation: orientation, textType: textType)
        case .iPad:
            return iPadFontSize(for: numberOfColumns, orientation: orientation, textType: textType)
        case .Mac:
            return macFontSize(for: numberOfColumns, textType: textType)
        }
    }
    
    private static func iPhoneFontSize(for columns: Int, orientation: Orientation, textType: TextType) -> CGFloat {
        switch columns {
        case 1:
            switch textType {
            case .title:
                return orientation == .vertical ? 22 : 20
            case .description:
                return orientation == .vertical ? 14 : 13
            case .subtask:
                return orientation == .vertical ? 12 : 11
            }
        case 2:
            switch textType {
            case .title:
                return orientation == .vertical ? 18 : 17
            case .description:
                return orientation == .vertical ? 12 : 11
            case .subtask:
                return orientation == .vertical ? 10 : 9
            }
        case 3:
            switch textType {
            case .title:
                return orientation == .vertical ? 16 : 15
            case .description:
                return orientation == .vertical ? 10 : 9
            case .subtask:
                return orientation == .vertical ? 8 : 7
            }
        default:
            switch textType {
            case .title:
                return orientation == .vertical ? 14 : 13
            case .description:
                return orientation == .vertical ? 8 : 7
            case .subtask:
                return orientation == .vertical ? 6 : 5
            }
        }
    }
    
    private static func iPadFontSize(for columns: Int, orientation: Orientation, textType: TextType) -> CGFloat {
        switch columns {
        case 1:
            switch textType {
            case .title:
                return orientation == .vertical ? 24 : 22
            case .description:
                return orientation == .vertical ? 18 : 16
            case .subtask:
                return orientation == .vertical ? 12 : 10
            }
        case 2:
            switch textType {
            case .title:
                return orientation == .vertical ? 22 : 20
            case .description:
                return orientation == .vertical ? 16 : 14
            case .subtask:
                return orientation == .vertical ? 10 : 9
            }
        case 3:
            switch textType {
            case .title:
                return orientation == .vertical ? 20 : 18
            case .description:
                return orientation == .vertical ? 14 : 12
            case .subtask:
                return orientation == .vertical ? 8 : 7
            }
        default:
            switch textType {
            case .title:
                return orientation == .vertical ? 18 : 16
            case .description:
                return orientation == .vertical ? 12 : 10
            case .subtask:
                return orientation == .vertical ? 8 : 6
            }
        }
    }
    
    private static func macFontSize(for columns: Int, textType: TextType) -> CGFloat {
        switch columns {
        case 1:
            switch textType {
            case .title:
                return 28
            case .description:
                return 20
            case .subtask:
                return 14
            }
        case 2:
            switch textType {
            case .title:
                return 26
            case .description:
                return 18
            case .subtask:
                return 12
            }
        case 3:
            switch textType {
            case .title:
                return 24
            case .description:
                return 16
            case .subtask:
                return 10
            }
        default:
            switch textType {
            case .title:
                return 22
            case .description:
                return 14
            case .subtask:
                return 10
            }
        }
    }
}

enum DeviceType {
    case iPhone, iPad, Mac
}

enum Orientation {
    case vertical, horizontal
}

enum TextType {
    case title, description, subtask
}
