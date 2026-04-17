import SwiftUI

struct DrawingPoint: Sendable {
    var location: CGPoint
    var timestamp: Date = .now
}

struct DrawingStroke: Identifiable, Sendable {
    let id = UUID()
    var points: [DrawingPoint] = []
    var color: Color
    var brushType: BrushType
    var lineWidth: CGFloat

    var isEmpty: Bool { points.isEmpty }
}
