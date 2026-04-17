import SwiftUI

enum BrushType: String, CaseIterable, Identifiable {
    case crayon
    case paintbrush
    case rainbow
    case sparkle
    case bubble
    case watercolor
    case neon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .crayon: "Crayon"
        case .paintbrush: "Paintbrush"
        case .rainbow: "Rainbow"
        case .sparkle: "Sparkle"
        case .bubble: "Bubble"
        case .watercolor: "Watercolor"
        case .neon: "Neon"
        }
    }

    var iconName: String {
        switch self {
        case .crayon: "pencil.tip"
        case .paintbrush: "paintbrush.pointed.fill"
        case .rainbow: "rainbow"
        case .sparkle: "sparkles"
        case .bubble: "bubble.fill"
        case .watercolor: "drop.fill"
        case .neon: "light.max"
        }
    }

    var defaultLineWidth: CGFloat {
        switch self {
        case .crayon: 8
        case .paintbrush: 12
        case .rainbow: 10
        case .sparkle: 6
        case .bubble: 20
        case .watercolor: 16
        case .neon: 8
        }
    }
}
