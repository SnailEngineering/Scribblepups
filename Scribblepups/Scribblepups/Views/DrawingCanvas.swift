import SwiftUI

struct DrawingCanvas: View {
    @Bindable var state: DrawingState

    var body: some View {
        ZStack {
            // Background image layer
            if let bgImage = state.backgroundImage {
                #if canImport(UIKit)
                Image(uiImage: bgImage)
                    .resizable()
                    .scaledToFill()
                #elseif canImport(AppKit)
                Image(nsImage: bgImage)
                    .resizable()
                    .scaledToFill()
                #endif
            }

            // Strokes layer
            Canvas { context, _ in
                for stroke in state.strokes {
                    drawStroke(stroke, in: &context)
                }
                if let current = state.currentStroke {
                    drawStroke(current, in: &context)
                }
            }

            // Stickers layer
            ForEach(state.stickers) { stamp in
                Text(stamp.sticker.emoji)
                    .font(.system(size: 44 * stamp.scale))
                    .position(stamp.position)
            }
        }
        .background(state.backgroundColor)
        .contentShape(Rectangle())
        .gesture(canvasGesture)
    }

    private var canvasGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                switch state.toolMode {
                case .draw, .eraser:
                    if state.currentStroke == nil {
                        state.beginStroke(at: value.startLocation)
                    }
                    state.continueStroke(to: value.location)
                case .stamp:
                    break
                }
            }
            .onEnded { value in
                switch state.toolMode {
                case .draw, .eraser:
                    state.endStroke()
                case .stamp:
                    state.placeSticker(at: value.location)
                }
            }
    }

    private func drawStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        guard stroke.points.count > 1 else {
            if let point = stroke.points.first {
                let rect = CGRect(
                    x: point.location.x - stroke.lineWidth / 2,
                    y: point.location.y - stroke.lineWidth / 2,
                    width: stroke.lineWidth,
                    height: stroke.lineWidth
                )
                context.fill(Circle().path(in: rect), with: .color(stroke.color))
            }
            return
        }

        switch stroke.brushType {
        case .crayon:
            drawCrayonStroke(stroke, in: &context)
        case .paintbrush:
            drawPaintbrushStroke(stroke, in: &context)
        case .rainbow:
            drawRainbowStroke(stroke, in: &context)
        case .sparkle:
            drawSparkleStroke(stroke, in: &context)
        case .bubble:
            drawBubbleStroke(stroke, in: &context)
        case .watercolor:
            drawWatercolorStroke(stroke, in: &context)
        case .neon:
            drawNeonStroke(stroke, in: &context)
        }
    }

    // MARK: - Brush Renderers

    private func smoothPath(from points: [DrawingPoint]) -> Path {
        var path = Path()
        path.move(to: points[0].location)
        for i in 1..<points.count {
            let prev = points[i - 1].location
            let curr = points[i].location
            let mid = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, control: prev)
        }
        return path
    }

    private func drawCrayonStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        let path = smoothPath(from: stroke.points)
        var ctx = context
        ctx.opacity = 0.85
        ctx.stroke(
            path,
            with: .color(stroke.color),
            style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round)
        )
    }

    private func drawPaintbrushStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        let path = smoothPath(from: stroke.points)
        var ctx = context
        ctx.opacity = 0.7
        ctx.stroke(
            path,
            with: .color(stroke.color),
            style: StrokeStyle(lineWidth: stroke.lineWidth * 1.5, lineCap: .round, lineJoin: .round)
        )
    }

    private func drawRainbowStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        for i in 1..<stroke.points.count {
            var segment = Path()
            segment.move(to: stroke.points[i - 1].location)
            segment.addLine(to: stroke.points[i].location)
            context.stroke(
                segment,
                with: .color(colors[i % colors.count]),
                style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }

    private func drawSparkleStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: stroke.points[0].location)
        for i in 1..<stroke.points.count {
            path.addLine(to: stroke.points[i].location)
        }
        context.stroke(
            path,
            with: .color(stroke.color),
            style: StrokeStyle(lineWidth: stroke.lineWidth * 0.5, lineCap: .round, lineJoin: .round)
        )
        for (i, point) in stroke.points.enumerated() where i % 4 == 0 {
            let size = stroke.lineWidth * CGFloat.random(in: 0.3...1.2)
            let rect = CGRect(
                x: point.location.x - size / 2,
                y: point.location.y - size / 2,
                width: size,
                height: size
            )
            var ctx = context
            ctx.opacity = Double.random(in: 0.5...1.0)
            ctx.fill(Circle().path(in: rect), with: .color(stroke.color))
        }
    }

    private func drawBubbleStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        for (i, point) in stroke.points.enumerated() where i % 3 == 0 {
            let size = stroke.lineWidth * CGFloat.random(in: 0.6...1.4)
            let rect = CGRect(
                x: point.location.x - size / 2,
                y: point.location.y - size / 2,
                width: size,
                height: size
            )
            var ctx = context
            ctx.opacity = 0.35
            ctx.fill(Circle().path(in: rect), with: .color(stroke.color))
            var ring = context
            ring.opacity = 0.5
            ring.stroke(Circle().path(in: rect), with: .color(stroke.color), style: StrokeStyle(lineWidth: 1.5))
        }
    }

    private func drawWatercolorStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        for offset in [-2.0, 0.0, 2.0] {
            let shifted = stroke.points.map {
                DrawingPoint(location: CGPoint(x: $0.location.x + offset, y: $0.location.y + offset))
            }
            let path = smoothPath(from: shifted)
            var ctx = context
            ctx.opacity = 0.2
            ctx.stroke(
                path,
                with: .color(stroke.color),
                style: StrokeStyle(lineWidth: stroke.lineWidth * 1.8, lineCap: .round, lineJoin: .round)
            )
        }
    }

    private func drawNeonStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        let path = smoothPath(from: stroke.points)
        var glow = context
        glow.opacity = 0.3
        glow.stroke(
            path,
            with: .color(stroke.color),
            style: StrokeStyle(lineWidth: stroke.lineWidth * 3, lineCap: .round, lineJoin: .round)
        )
        context.stroke(
            path,
            with: .color(.white),
            style: StrokeStyle(lineWidth: stroke.lineWidth * 0.5, lineCap: .round, lineJoin: .round)
        )
    }
}
