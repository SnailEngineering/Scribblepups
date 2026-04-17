import SwiftUI

enum Haptics {
    #if canImport(UIKit)
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #else
    static func tap() {}
    static func success() {}
    static func selection() {}
    #endif
}
