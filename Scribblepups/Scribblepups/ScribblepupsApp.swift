import SwiftUI
import OSLog

@main
struct ScribblepupsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(iOS)
                .statusBarHidden()
                .persistentSystemOverlays(.hidden)
                #endif
        }
    }

    init() {
        Logger.app.info("Scribblepups launched")
    }
}
