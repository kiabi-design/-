import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL?
    let htmlString: String?
    @Binding var reloadTrigger: UUID

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastReload != reloadTrigger {
            context.coordinator.lastReload = reloadTrigger
            webView.reload()
            return
        }

        if let url = url {
            if context.coordinator.lastURL != url {
                context.coordinator.lastURL = url
                context.coordinator.lastHTML = nil
                let accessDir = url.deletingLastPathComponent()
                webView.loadFileURL(url, allowingReadAccessTo: accessDir)
            }
        } else if let html = htmlString {
            if context.coordinator.lastHTML != html {
                context.coordinator.lastHTML = html
                context.coordinator.lastURL = nil
                webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var lastURL: URL?
        var lastHTML: String?
        var lastReload = UUID()
    }
}
