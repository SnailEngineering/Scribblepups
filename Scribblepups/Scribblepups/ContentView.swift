import SwiftUI
import OSLog

struct ContentView: View {
    @State private var drawingState = DrawingState()
    @State private var showBrushPicker = false
    @State private var showStickerPicker = false
    @State private var canvasSize: CGSize = .zero
    @State private var showShareSheet = false
    @State private var shareImage: PlatformImage?
    @State private var showSaveConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            ToolBar(
                state: drawingState,
                showBrushPicker: $showBrushPicker,
                showStickerPicker: $showStickerPicker,
                onSave: saveToPhotos,
                onShare: shareDrawing
            )
            .padding(.vertical, 8)

            if showBrushPicker {
                BrushPicker(
                    selectedBrush: $drawingState.selectedBrush,
                    lineWidth: $drawingState.lineWidth
                )
                .padding(.bottom, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if showStickerPicker {
                StickerPicker(toolMode: $drawingState.toolMode)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            DrawingCanvas(state: drawingState)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 8)
                .overlay {
                    GeometryReader { geo in
                        Color.clear.onAppear { canvasSize = geo.size }
                    }
                }

            ColorPalette(selectedColor: $drawingState.selectedColor)
                .padding(.vertical, 8)
        }
        .animation(.easeInOut(duration: 0.2), value: showBrushPicker)
        .animation(.easeInOut(duration: 0.2), value: showStickerPicker)
        .overlay {
            if showSaveConfirmation {
                SaveConfirmationOverlay()
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { showSaveConfirmation = false }
                        }
                    }
            }
        }
        #if canImport(UIKit)
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
        #endif
    }

    private func renderCanvas() -> PlatformImage? {
        let canvasView = DrawingCanvas(state: drawingState)
            .frame(width: canvasSize.width, height: canvasSize.height)
        return CanvasRenderer.renderImage(from: canvasView, size: canvasSize)
    }

    private func saveToPhotos() {
        guard let image = renderCanvas() else { return }
        #if canImport(UIKit)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation { showSaveConfirmation = true }
        Logger.storage.info("Drawing saved to Photos")
        #endif
    }

    private func shareDrawing() {
        guard let image = renderCanvas() else { return }
        shareImage = image
        showShareSheet = true
    }
}

struct SaveConfirmationOverlay: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Saved!")
                .font(.headline)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#Preview {
    ContentView()
}
