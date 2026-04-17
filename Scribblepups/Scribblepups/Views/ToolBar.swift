import SwiftUI

struct ToolBar: View {
    @Bindable var state: DrawingState
    @Binding var showBrushPicker: Bool

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
        }
        .padding(.horizontal, 12)
    }
}
