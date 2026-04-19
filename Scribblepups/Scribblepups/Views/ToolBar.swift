import SwiftUI
import PhotosUI

struct ToolBar: View {
    @Bindable var state: DrawingState
    @Binding var showBrushPicker: Bool
    @Binding var showStickerPicker: Bool
    var onSave: () -> Void
    var onShare: () -> Void
    @State private var photoSelection: PhotosPickerItem?
    @State private var photoImportError: String?
    @State private var showPhotoImportError = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isCompact: Bool { sizeClass == .compact }
    private var buttonSize: CGFloat { isCompact ? 36 : 44 }
    private var buttonFont: Font { isCompact ? .body : .title2 }
    private var outerPadding: CGFloat { isCompact ? 8 : 12 }
    private var itemSpacing: CGFloat { isCompact ? 2 : 4 }

    var body: some View {
        HStack(spacing: 0) {
            // Drawing tools
            HStack(spacing: itemSpacing) {
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
                        .font(buttonFont)
                        .frame(width: buttonSize, height: buttonSize)
                }
                .accessibilityLabel("Import photo")
            }
            .padding(.horizontal, itemSpacing)
            .padding(.vertical, itemSpacing)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // History controls
            HStack(spacing: itemSpacing) {
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
            .padding(.horizontal, itemSpacing)
            .padding(.vertical, itemSpacing)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // Export controls
            HStack(spacing: itemSpacing) {
                toolButton(icon: "square.and.arrow.down", isActive: false, label: "Save") {
                    onSave()
                }
                .disabled(!hasContent)

                toolButton(icon: "square.and.arrow.up", isActive: false, label: "Share") {
                    onShare()
                }
                .disabled(!hasContent)
            }
            .padding(.horizontal, itemSpacing)
            .padding(.vertical, itemSpacing)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, outerPadding)
        .onChange(of: photoSelection) { _, newValue in
            Task {
                defer { photoSelection = nil }
                guard let item = newValue else { return }
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        photoImportError = "Could not load the selected photo."
                        showPhotoImportError = true
                        return
                    }
                    #if canImport(UIKit)
                    guard let image = UIImage(data: data) else {
                        photoImportError = "The selected photo could not be decoded."
                        showPhotoImportError = true
                        return
                    }
                    state.setBackgroundImage(image)
                    #elseif canImport(AppKit)
                    guard let image = NSImage(data: data) else {
                        photoImportError = "The selected photo could not be decoded."
                        showPhotoImportError = true
                        return
                    }
                    state.setBackgroundImage(image)
                    #endif
                } catch {
                    photoImportError = error.localizedDescription
                    showPhotoImportError = true
                }
            }
        }
        .alert("Couldn't Import Photo", isPresented: $showPhotoImportError) {
            Button("OK") {}
        } message: {
            Text(photoImportError ?? "An unknown error occurred.")
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
                .font(buttonFont)
                .frame(width: buttonSize, height: buttonSize)
                .background(isActive ? Color.accentColor.opacity(0.2) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
