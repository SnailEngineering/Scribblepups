import SwiftUI
import OSLog

struct ContentView: View {
    @State private var drawingState = DrawingState()
    @State private var showBrushPicker = false
    @State private var showStickerPicker = false
    @State private var canvasSize: CGSize = .zero
    @State private var showShareSheet = false
    @State private var shareImage: PlatformImage?
    @State private var showSaveConfetti = false

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

            ZStack {
                DrawingCanvas(state: drawingState)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if drawingState.strokes.isEmpty && drawingState.stickers.isEmpty && drawingState.backgroundImage == nil {
                    EmptyCanvasHint()
                        .allowsHitTesting(false)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
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
            if showSaveConfetti {
                ConfettiOverlay()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { showSaveConfetti = false }
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
        #endif
        Haptics.success()
        withAnimation { showSaveConfetti = true }
        Logger.storage.info("Drawing saved to Photos")
    }

    private func shareDrawing() {
        guard let image = renderCanvas() else { return }
        shareImage = image
        showShareSheet = true
        Haptics.tap()
    }
}

struct EmptyCanvasHint: View {
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.draw.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
                .offset(y: bounce ? -6 : 6)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: bounce)
            Text("Draw something awesome!")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .onAppear { bounce = true }
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
