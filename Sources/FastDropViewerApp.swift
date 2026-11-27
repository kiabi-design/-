import SwiftUI

@main
struct FastDropViewerApp: App {
    @State private var incomingURL: URL?

    var body: some Scene {
        WindowGroup {
            ContentView(externalURL: $incomingURL)
                .onOpenURL { url in
                    incomingURL = url
                }
        }
    }
}
