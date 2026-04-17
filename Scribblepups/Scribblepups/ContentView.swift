import SwiftUI

struct ContentView: View {
    @State private var drawingState = DrawingState()
    @State private var showBrushPicker = false

    var body: some View {
        VStack(spacing: 0) {
            ToolBar(state: drawingState, showBrushPicker: $showBrushPicker)
                .padding(.vertical, 8)

            if showBrushPicker {
                BrushPicker(
                    selectedBrush: $drawingState.selectedBrush,
                    lineWidth: $drawingState.lineWidth
                )
                .padding(.bottom, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            DrawingCanvas(state: drawingState)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 8)

            ColorPalette(selectedColor: $drawingState.selectedColor)
                .padding(.vertical, 8)
        }
        .animation(.easeInOut(duration: 0.2), value: showBrushPicker)
    }
}

#Preview {
    ContentView()
}
