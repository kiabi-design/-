import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var externalURL: URL?
    @State private var selectedFileURL: URL?
    @State private var showPicker = false
    @State private var showToolbar = true
    @State private var reloadTrigger = UUID()

    private var activeURL: URL? {
        selectedFileURL ?? externalURL
    }

    private var bundledHTML: String {
        if let url = Bundle.main.url(forResource: "index", withExtension: "html"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            return content
        }
        return """
        <!doctype html>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <body style="font-family:-apple-system;display:grid;place-items:center;height:100vh;margin:0;background:#111;color:#fff">
        <p>Нажмите «Открыть HTML» сверху</p>
        </body>
        """
    }

    var body: some View {
        ZStack(alignment: .top) {
            WebView(
                url: activeURL,
                htmlString: activeURL == nil ? bundledHTML : nil,
                reloadTrigger: $reloadTrigger
            )
            .ignoresSafeArea()

            if showToolbar {
                HStack(spacing: 8) {
                    Button {
                        showPicker = true
                    } label: {
                        Label("Открыть HTML", systemImage: "doc.badge.plus")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    Button {
                        reloadTrigger = UUID()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    if activeURL != nil {
                        Button {
                            selectedFileURL = nil
                            externalURL = nil
                        } label: {
                            Image(systemName: "house")
                                .font(.subheadline.weight(.semibold))
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showToolbar = false
                        }
                    } label: {
                        Image(systemName: "eye.slash")
                            .font(.subheadline.weight(.semibold))
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
            } else {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showToolbar = true
                        }
                    } label: {
                        Image(systemName: "eye")
                            .font(.caption.weight(.semibold))
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 6)
                }
            }
        }
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [.html],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                copyToSandboxAndOpen(url)
            }
        }
        .onChange(of: externalURL) { newValue in
            if let url = newValue {
                copyToSandboxAndOpen(url)
            }
        }
    }

    private func copyToSandboxAndOpen(_ sourceURL: URL) {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed { sourceURL.stopAccessingSecurityScopedResource() }
        }

        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = docs.appendingPathComponent(sourceURL.lastPathComponent)

        try? fm.removeItem(at: dest)
        do {
            try fm.copyItem(at: sourceURL, to: dest)
            selectedFileURL = dest
        } catch {
            selectedFileURL = sourceURL
        }
    }
}
