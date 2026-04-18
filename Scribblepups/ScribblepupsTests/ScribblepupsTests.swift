import Testing
import SwiftUI
@testable import Scribblepups

@MainActor
struct ScribblepupsTests {

    @Test func strokeBeginAndEnd() {
        let state = DrawingState()
        state.beginStroke(at: CGPoint(x: 10, y: 10))
        #expect(state.currentStroke != nil)
        state.continueStroke(to: CGPoint(x: 20, y: 20))
        state.endStroke()
        #expect(state.strokes.count == 1)
        #expect(state.currentStroke == nil)
        #expect(state.canUndo)
        #expect(!state.canRedo)
    }

    @Test func undoStroke() {
        let state = DrawingState()
        state.beginStroke(at: CGPoint(x: 10, y: 10))
        state.continueStroke(to: CGPoint(x: 20, y: 20))
        state.endStroke()
        state.undo()
        #expect(state.strokes.isEmpty)
        #expect(!state.canUndo)
        #expect(state.canRedo)
    }

    @Test func redoStroke() {
        let state = DrawingState()
        state.beginStroke(at: CGPoint(x: 10, y: 10))
        state.continueStroke(to: CGPoint(x: 20, y: 20))
        state.endStroke()
        state.undo()
        state.redo()
        #expect(state.strokes.count == 1)
        #expect(state.canUndo)
        #expect(!state.canRedo)
    }

    @Test func newActionClearsRedoStack() {
        let state = DrawingState()
        state.beginStroke(at: CGPoint(x: 0, y: 0))
        state.continueStroke(to: CGPoint(x: 10, y: 10))
        state.endStroke()
        state.undo()
        #expect(state.canRedo)
        state.beginStroke(at: CGPoint(x: 5, y: 5))
        state.continueStroke(to: CGPoint(x: 15, y: 15))
        state.endStroke()
        #expect(!state.canRedo)
    }

    @Test func clearCanvas() {
        let state = DrawingState()
        state.beginStroke(at: CGPoint(x: 10, y: 10))
        state.continueStroke(to: CGPoint(x: 20, y: 20))
        state.endStroke()
        state.clearCanvas()
        #expect(state.strokes.isEmpty)
        #expect(state.stickers.isEmpty)
        #expect(!state.canUndo)
        #expect(!state.canRedo)
        #expect(state.backgroundImage == nil)
    }

    @Test func undoStackDepthLimit() {
        let state = DrawingState()
        for i in 0..<110 {
            state.beginStroke(at: CGPoint(x: CGFloat(i), y: 0))
            state.continueStroke(to: CGPoint(x: CGFloat(i + 1), y: 1))
            state.endStroke()
        }
        #expect(state.strokes.count == 110)
        var undoCount = 0
        while state.canUndo {
            state.undo()
            undoCount += 1
        }
        #expect(undoCount == 100)
        #expect(state.strokes.count == 10)
    }

    @Test func stickerPlacement() {
        let state = DrawingState()
        state.toolMode = .stamp(.star)
        state.placeSticker(at: CGPoint(x: 50, y: 50))
        #expect(state.stickers.count == 1)
        #expect(state.stickers.first?.sticker == .star)
        #expect(state.canUndo)
    }

    @Test func undoSticker() {
        let state = DrawingState()
        state.toolMode = .stamp(.heart)
        state.placeSticker(at: CGPoint(x: 50, y: 50))
        state.undo()
        #expect(state.stickers.isEmpty)
        #expect(!state.canUndo)
        #expect(state.canRedo)
    }

    @Test func redoSticker() {
        let state = DrawingState()
        state.toolMode = .stamp(.moon)
        state.placeSticker(at: CGPoint(x: 30, y: 30))
        state.undo()
        state.redo()
        #expect(state.stickers.count == 1)
        #expect(state.stickers.first?.sticker == .moon)
        #expect(!state.canRedo)
    }

    @Test func eraserStrokeIsMarked() {
        let state = DrawingState()
        state.toolMode = .eraser
        state.beginStroke(at: CGPoint(x: 0, y: 0))
        state.continueStroke(to: CGPoint(x: 10, y: 10))
        state.endStroke()
        #expect(state.strokes.first?.isEraser == true)
        #expect(state.strokes.first?.lineWidth == state.lineWidth * 3)
    }

    @Test func emptyStrokeIsDiscarded() {
        let state = DrawingState()
        state.beginStroke(at: CGPoint(x: 0, y: 0))
        // Don't add any points, immediately end
        state.currentStroke?.points.removeAll()
        state.endStroke()
        #expect(state.strokes.isEmpty)
        #expect(!state.canUndo)
    }
}
