import SwiftUI
import OSLog

@Observable
final class DrawingState {
    var strokes: [DrawingStroke] = []
    var currentStroke: DrawingStroke?
    var stickers: [StickerStamp] = []
    var selectedColor: Color = .black
    var selectedBrush: BrushType = .crayon
    var lineWidth: CGFloat = 8
    var backgroundColor: Color = .white
    var backgroundImage: PlatformImage?
    var toolMode: ToolMode = .draw

    private var undoStack: [UndoRecord] = []
    private var redoStack: [RedoRecord] = []
    private let maxUndoDepth = 100

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // MARK: - Drawing

    func beginStroke(at point: CGPoint) {
        guard toolMode == .draw || toolMode == .eraser else { return }
        let isEraser = toolMode == .eraser
        let stroke = DrawingStroke(
            points: [DrawingPoint(location: point)],
            color: isEraser ? .clear : selectedColor,
            brushType: isEraser ? .crayon : selectedBrush,
            lineWidth: isEraser ? lineWidth * 3 : lineWidth,
            isEraser: isEraser
        )
        currentStroke = stroke
        Logger.canvas.debug("Stroke began at \(point.x, privacy: .public), \(point.y, privacy: .public)")
    }

    func continueStroke(to point: CGPoint) {
        currentStroke?.points.append(DrawingPoint(location: point))
    }

    func endStroke() {
        guard let stroke = currentStroke, !stroke.isEmpty else {
            currentStroke = nil
            return
        }
        strokes.append(stroke)
        undoStack.append(.stroke)
        if undoStack.count > maxUndoDepth {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        currentStroke = nil
        Logger.canvas.debug("Stroke ended with \(stroke.points.count, privacy: .public) points")
    }

    // MARK: - Stickers

    func placeSticker(at point: CGPoint) {
        guard case .stamp(let sticker) = toolMode else { return }
        let stamp = StickerStamp(sticker: sticker, position: point)
        stickers.append(stamp)
        undoStack.append(.sticker)
        if undoStack.count > maxUndoDepth {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        Logger.canvas.debug("Sticker placed: \(sticker.rawValue, privacy: .public)")
    }

    // MARK: - Background

    func setBackgroundImage(_ image: PlatformImage?) {
        backgroundImage = image
        Logger.canvas.info("Background image updated")
    }

    // MARK: - Undo / Redo

    func undo() {
        guard let action = undoStack.popLast() else { return }
        switch action {
        case .stroke:
            if let last = strokes.popLast() {
                redoStack.append(.stroke(last))
            }
        case .sticker:
            if let last = stickers.popLast() {
                redoStack.append(.sticker(last))
            }
        }
        Logger.canvas.debug("Undo performed")
    }

    func redo() {
        guard let action = redoStack.popLast() else { return }
        switch action {
        case .stroke(let stroke):
            strokes.append(stroke)
            undoStack.append(.stroke)
        case .sticker(let stamp):
            stickers.append(stamp)
            undoStack.append(.sticker)
        }
        Logger.canvas.debug("Redo performed")
    }

    func clearCanvas() {
        strokes.removeAll()
        stickers.removeAll()
        undoStack.removeAll()
        redoStack.removeAll()
        currentStroke = nil
        backgroundImage = nil
        Logger.canvas.info("Canvas cleared")
    }
}

private enum UndoRecord {
    case stroke
    case sticker
}

private enum RedoRecord {
    case stroke(DrawingStroke)
    case sticker(StickerStamp)
}
