import SwiftUI
import OSLog

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

@MainActor
struct CanvasRenderer {
    static func renderImage(from view: some View, size: CGSize) -> PlatformImage? {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 3.0
        #if canImport(UIKit)
        let image = renderer.uiImage
        #elseif canImport(AppKit)
        let image = renderer.nsImage
        #endif
        if image == nil {
            Logger.storage.error("Failed to render canvas image")
        }
        return image
    }
}
