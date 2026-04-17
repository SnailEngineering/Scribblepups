import Foundation

enum ToolMode: Equatable, Sendable {
    case draw
    case stamp(Sticker)
    case eraser
}
