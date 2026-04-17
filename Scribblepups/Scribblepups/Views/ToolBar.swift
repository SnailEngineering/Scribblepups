import SwiftUI
import PhotosUI

struct ToolBar: View {
    @Bindable var state: DrawingState
    @Binding var showBrushPicker: Bool
    @Binding var showStickerPicker: Bool
    var onSave: () -> Void
    var onShare: () -> Void
    @State private var photoSelection: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 12) {
            // Brush
            Button {
                state.toolMode = .draw
                showBrushPicker.toggle()
                showStickerPicker = false
            } label: {
                Image(systemName: state.selectedBrush.iconName)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(state.toolMode == .draw ? Color.accentColor.opacity(0.15) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Brush picker")

            // Eraser
            Button {
                state.toolMode = state.toolMode == .eraser ? .draw : .eraser
                showBrushPicker = false
                showStickerPicker = false
            } label: {
                Image(systemName: "eraser.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(state.toolMode == .eraser ? Color.accentColor.opacity(0.15) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Eraser")

            // Stickers
            Button {
                if case .stamp = state.toolMode {
                    state.toolMode = .draw
                    showStickerPicker = false
                } else {
                    state.toolMode = .stamp(.star)
                    showStickerPicker = true
                    showBrushPicker = false
                }
            } label: {
                Image(systemName: "face.smiling.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background({
                        if case .stamp = state.toolMode { return Color.accentColor.opacity(0.15) }
                        return Color.clear
                    }())
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Stickers")

            // Photo import
            PhotosPicker(selection: $photoSelection, matching: .images) {
                Image(systemName: "photo.badge.plus.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Import photo")

            Spacer()

            // Undo / Redo
            Button { state.undo() } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .disabled(!state.canUndo)

            Button { state.redo() } label: {
                Image(systemName: "arrow.uturn.forward.circle.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .disabled(!state.canRedo)

            Button { state.clearCanvas() } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .disabled(!state.canUndo)

            Spacer()

            // Save / Share
            Button(action: onSave) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .disabled(state.strokes.isEmpty && state.stickers.isEmpty)

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .disabled(state.strokes.isEmpty && state.stickers.isEmpty)
        }
        .padding(.horizontal, 12)
        .onChange(of: photoSelection) { _, newValue in
            Task {
                guard let item = newValue,
                      let data = try? await item.loadTransferable(type: Data.self) else { return }
                #if canImport(UIKit)
                state.setBackgroundImage(UIImage(data: data))
                #elseif canImport(AppKit)
                state.setBackgroundImage(NSImage(data: data))
                #endif
                photoSelection = nil
            }
        }
    }
}
