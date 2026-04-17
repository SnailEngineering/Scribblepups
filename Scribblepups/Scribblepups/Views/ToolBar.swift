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
        HStack(spacing: 0) {
            // Drawing tools
            HStack(spacing: 4) {
                toolButton(
                    icon: state.selectedBrush.iconName,
                    isActive: state.toolMode == .draw,
                    label: "Brush picker"
                ) {
                    state.toolMode = .draw
                    showBrushPicker.toggle()
                    showStickerPicker = false
                    Haptics.selection()
                }

                toolButton(
                    icon: "eraser.fill",
                    isActive: state.toolMode == .eraser,
                    label: "Eraser"
                ) {
                    state.toolMode = state.toolMode == .eraser ? .draw : .eraser
                    showBrushPicker = false
                    showStickerPicker = false
                    Haptics.selection()
                }

                toolButton(
                    icon: "face.smiling.fill",
                    isActive: isStampMode,
                    label: "Stickers"
                ) {
                    if isStampMode {
                        state.toolMode = .draw
                        showStickerPicker = false
                    } else {
                        state.toolMode = .stamp(.star)
                        showStickerPicker = true
                        showBrushPicker = false
                    }
                    Haptics.selection()
                }

                PhotosPicker(selection: $photoSelection, matching: .images) {
                    Image(systemName: "photo.badge.plus.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Import photo")
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // History controls
            HStack(spacing: 4) {
                toolButton(icon: "arrow.uturn.backward", isActive: false, label: "Undo") {
                    state.undo()
                    Haptics.tap()
                }
                .disabled(!state.canUndo)

                toolButton(icon: "arrow.uturn.forward", isActive: false, label: "Redo") {
                    state.redo()
                    Haptics.tap()
                }
                .disabled(!state.canRedo)

                toolButton(icon: "trash", isActive: false, label: "Clear canvas") {
                    state.clearCanvas()
                    Haptics.tap()
                }
                .disabled(!state.canUndo)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // Export controls
            HStack(spacing: 4) {
                toolButton(icon: "square.and.arrow.down", isActive: false, label: "Save") {
                    onSave()
                }
                .disabled(!hasContent)

                toolButton(icon: "square.and.arrow.up", isActive: false, label: "Share") {
                    onShare()
                }
                .disabled(!hasContent)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
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

    private var isStampMode: Bool {
        if case .stamp = state.toolMode { return true }
        return false
    }

    private var hasContent: Bool {
        !state.strokes.isEmpty || !state.stickers.isEmpty
    }

    private func toolButton(
        icon: String,
        isActive: Bool,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(isActive ? Color.accentColor.opacity(0.2) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
