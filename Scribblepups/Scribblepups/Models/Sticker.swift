import SwiftUI

struct StickerStamp: Identifiable, Sendable {
    let id = UUID()
    var sticker: Sticker
    var position: CGPoint
    var scale: CGFloat = 1.0
}

enum Sticker: String, CaseIterable, Identifiable {
    case star
    case heart
    case moon
    case sun
    case flower
    case butterfly
    case paw
    case fish
    case rocket
    case rainbow

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .star: "⭐️"
        case .heart: "❤️"
        case .moon: "🌙"
        case .sun: "☀️"
        case .flower: "🌸"
        case .butterfly: "🦋"
        case .paw: "🐾"
        case .fish: "🐠"
        case .rocket: "🚀"
        case .rainbow: "🌈"
        }
    }
}
