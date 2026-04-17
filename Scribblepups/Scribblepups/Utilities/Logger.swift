import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.scribblepups"

    /// General app lifecycle events
    static let app = Logger(subsystem: subsystem, category: "app")

    /// Drawing canvas events
    static let canvas = Logger(subsystem: subsystem, category: "canvas")

    /// Brush and tool selection events
    static let tools = Logger(subsystem: subsystem, category: "tools")

    /// File save and share events
    static let storage = Logger(subsystem: subsystem, category: "storage")
}
