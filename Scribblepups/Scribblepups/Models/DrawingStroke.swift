import SwiftUI

struct DrawingPoint: Sendable {
    var location: CGPoint
    var variation: CGFloat = CGFloat.random(in: 0.5...1.5)
}

struct DrawingStroke: Identifiable, Sendable {
    let id = UUID()
    var points: [DrawingPoint] = []
    var color: Color
    var brushType: BrushType
    var lineWidth: CGFloat
    var isEraser: Bool = false

    var isEmpty: Bool { points.isEmpty }
}
