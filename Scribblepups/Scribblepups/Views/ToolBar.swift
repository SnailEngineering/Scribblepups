import SwiftUI

struct ToolBar: View {
    @Bindable var state: DrawingState
    @Binding var showBrushPicker: Bool
    var onSave: () -> Void
    var onShare: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                showBrushPicker.toggle()
            } label: {
                Image(systemName: state.selectedBrush.iconName)
                    .font(.title2)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel("Brush picker")

            Spacer()

            Button {
                state.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title2)
                    .frame(width: 48, height: 48)
            }
            .disabled(!state.canUndo)
            .accessibilityLabel("Undo")

            Button {
                state.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward.circle.fill")
                    .font(.title2)
                    .frame(width: 48, height: 48)
            }
            .disabled(!state.canRedo)
            .accessibilityLabel("Redo")

            Button {
                state.clearCanvas()
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .frame(width: 48, height: 48)
            }
            .disabled(!state.canUndo)
            .accessibilityLabel("Clear canvas")

            Spacer()

            Button(action: onSave) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.title2)
                    .frame(width: 48, height: 48)
            }
            .disabled(state.strokes.isEmpty)
            .accessibilityLabel("Save to photos")

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.title2)
                    .frame(width: 48, height: 48)
            }
            .disabled(state.strokes.isEmpty)
            .accessibilityLabel("Share")
        }
        .padding(.horizontal, 12)
    }
}
