//
//  MediaNoteItemEmbedView.swift
//  Notelet
//

import SwiftUI
import WebKit

/// Displays a web-based media player using a platform embed URL.
struct MediaNoteItemEmbedView: UIViewRepresentable {
    let embedURL: URL
    let isActive: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        loadEmbed(in: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let currentURL = webView.url?.absoluteString

        if isActive {
            if currentURL == nil || currentURL == "about:blank" {
                loadEmbed(in: webView)
            }
        } else if currentURL != "about:blank" {
            webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }

    private func loadEmbed(in webView: WKWebView) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
        <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
        iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
        </style>
        </head>
        <body>
        <iframe
            src="\(embedURL.absoluteString)"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
            allowfullscreen>
        </iframe>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: embedURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            let scheme = navigationAction.request.url?.scheme?.lowercased() ?? ""
            return (scheme == "http" || scheme == "https" || scheme == "about") ? .allow : .cancel
        }
    }
}
