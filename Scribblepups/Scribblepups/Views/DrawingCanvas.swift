import SwiftUI

struct DrawingCanvas: View {
    @Bindable var state: DrawingState
    @GestureState private var stampPreviewLocation: CGPoint? = nil

    var body: some View {
        ZStack {
            state.backgroundColor

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

            // Strokes layer — drawingGroup isolates blend modes so eraser cuts through correctly
            Canvas { context, _ in
                for stroke in state.strokes {
                    drawStroke(stroke, in: &context)
                }
                if let current = state.currentStroke {
                    drawStroke(current, in: &context)
                }
            }
            .drawingGroup()

            // Stickers layer
            ForEach(state.stickers) { stamp in
                Text(stamp.sticker.emoji)
                    .font(.system(size: 44 * stamp.scale))
                    .position(stamp.position)
            }

            // Stamp preview follows the finger while dragging
            if case .stamp(let sticker) = state.toolMode, let loc = stampPreviewLocation {
                Text(sticker.emoji)
                    .font(.system(size: 44))
                    .position(loc)
                    .opacity(0.6)
                    .allowsHitTesting(false)
            }
        }
        .contentShape(Rectangle())
        .gesture(canvasGesture)
    }

    private var canvasGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($stampPreviewLocation) { value, location, _ in
                if case .stamp = state.toolMode {
                    location = value.location
                }
            }
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
        if stroke.isEraser {
            drawEraserStroke(stroke, in: &context)
            return
        }

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
        guard !points.isEmpty else { return Path() }
        var path = Path()
        path.move(to: points[0].location)
        for i in 1..<points.count {
            let prev = points[i - 1].location
            let curr = points[i].location
            let mid = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, control: prev)
        }
        if let last = points.last {
            path.addLine(to: last.location)
        }
        return path
    }

    private func drawEraserStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        let path = smoothPath(from: stroke.points)
        var ctx = context
        ctx.blendMode = .clear
        ctx.stroke(
            path,
            with: .color(.white),
            style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round)
        )
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
        // Build one path per color band, then stroke each once — reduces draw calls from N to 6
        var paths = Array(repeating: Path(), count: colors.count)
        for i in 1..<stroke.points.count {
            let idx = i % colors.count
            paths[idx].move(to: stroke.points[i - 1].location)
            paths[idx].addLine(to: stroke.points[i].location)
        }
        let style = StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round)
        for (i, path) in paths.enumerated() {
            context.stroke(path, with: .color(colors[i]), style: style)
        }
    }

    private func drawSparkleStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        guard !stroke.points.isEmpty else { return }
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
            // Use pre-seeded variation so sparkles don't flicker on re-render
            let size = stroke.lineWidth * point.variation * 0.8
            let rect = CGRect(
                x: point.location.x - size / 2,
                y: point.location.y - size / 2,
                width: size,
                height: size
            )
            var ctx = context
            ctx.opacity = Double(0.5 + (point.variation - 0.5) * 0.5)
            ctx.fill(Circle().path(in: rect), with: .color(stroke.color))
        }
    }

    private func drawBubbleStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        for (i, point) in stroke.points.enumerated() where i % 3 == 0 {
            // Use pre-seeded variation so bubbles don't flicker on re-render
            let size = stroke.lineWidth * point.variation
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
