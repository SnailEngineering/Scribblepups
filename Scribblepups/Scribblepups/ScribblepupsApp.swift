import SwiftUI
import OSLog

@main
struct ScribblepupsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        Logger.app.info("Scribblepups launched")
    }
}
