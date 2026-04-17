import SwiftUI

enum BrushType: String, CaseIterable, Identifiable {
    case crayon
    case paintbrush
    case rainbow
    case sparkle
    case neon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .crayon: "Crayon"
        case .paintbrush: "Paintbrush"
        case .rainbow: "Rainbow"
        case .sparkle: "Sparkle"
        case .neon: "Neon"
        }
    }

    var iconName: String {
        switch self {
        case .crayon: "pencil.tip"
        case .paintbrush: "paintbrush.pointed.fill"
        case .rainbow: "rainbow"
        case .sparkle: "sparkles"
        case .neon: "light.max"
        }
    }

    var defaultLineWidth: CGFloat {
        switch self {
        case .crayon: 8
        case .paintbrush: 12
        case .rainbow: 10
        case .sparkle: 6
        case .neon: 8
        }
    }
}
