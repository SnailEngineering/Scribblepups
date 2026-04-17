import SwiftUI
import OSLog

@Observable
final class DrawingState {
    var strokes: [DrawingStroke] = []
    var currentStroke: DrawingStroke?
    var selectedColor: Color = .black
    var selectedBrush: BrushType = .crayon
    var lineWidth: CGFloat = 8
    var backgroundColor: Color = .white

    private var undoStack: [DrawingStroke] = []

    var canUndo: Bool { !strokes.isEmpty }
    var canRedo: Bool { !undoStack.isEmpty }

    func beginStroke(at point: CGPoint) {
        let stroke = DrawingStroke(
            points: [DrawingPoint(location: point)],
            color: selectedColor,
            brushType: selectedBrush,
            lineWidth: lineWidth
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
        undoStack.removeAll()
        currentStroke = nil
        Logger.canvas.debug("Stroke ended with \(stroke.points.count, privacy: .public) points")
    }

    func undo() {
        guard let last = strokes.popLast() else { return }
        undoStack.append(last)
        Logger.canvas.debug("Undo performed, \(self.strokes.count, privacy: .public) strokes remaining")
    }

    func redo() {
        guard let last = undoStack.popLast() else { return }
        strokes.append(last)
        Logger.canvas.debug("Redo performed, \(self.strokes.count, privacy: .public) strokes total")
    }

    func clearCanvas() {
        strokes.removeAll()
        undoStack.removeAll()
        currentStroke = nil
        Logger.canvas.info("Canvas cleared")
    }
}
