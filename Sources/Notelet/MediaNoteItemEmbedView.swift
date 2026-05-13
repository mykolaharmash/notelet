//
//  MediaNoteItemEmbedView.swift
//  Notelet
//

import SwiftUI
import UIKit
import WebKit

/// Displays a web-based media player using a platform embed URL.
struct MediaNoteItemEmbedView: UIViewRepresentable {
  let embedURL: URL
  let isActive: Bool

  private static let blankURL = URL(string: "about:blank")!

  private let allowedOrigin: WebOrigin

  init?(embedURL: URL, isActive: Bool, allowedHosts: Set<String>) {
    guard let allowedOrigin = WebOrigin(url: embedURL, allowedHosts: allowedHosts) else {
      return nil
    }

    self.embedURL = embedURL
    self.isActive = isActive
    self.allowedOrigin = allowedOrigin
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(allowedOrigin: allowedOrigin)
  }

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    configuration.mediaTypesRequiringUserActionForPlayback = .all
    configuration.websiteDataStore = .nonPersistent()
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = false

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    webView.scrollView.isScrollEnabled = false
    webView.backgroundColor = .black
    webView.isOpaque = true
    webView.customUserAgent =
      "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

    if isActive {
      loadEmbed(in: webView, coordinator: context.coordinator)
    }

    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    context.coordinator.allowedOrigin = allowedOrigin

    if isActive {
      if context.coordinator.loadedEmbedURL != embedURL || webView.url?.isAboutBlank == true {
        loadEmbed(in: webView, coordinator: context.coordinator)
      }
    } else if webView.url?.isAboutBlank != true {
      context.coordinator.loadedEmbedURL = nil
      webView.stopLoading()
      webView.load(URLRequest(url: Self.blankURL))
      Self.clearWebsiteData(in: webView)
    }
  }

  static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
    coordinator.loadedEmbedURL = nil
    webView.stopLoading()
    webView.load(URLRequest(url: Self.blankURL))
    clearWebsiteData(in: webView)
    webView.navigationDelegate = nil
    webView.removeFromSuperview()
  }

  private static func clearWebsiteData(in webView: WKWebView) {
    webView.configuration.websiteDataStore.removeData(
      ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
      modifiedSince: .distantPast
    ) {}
  }

  private func loadEmbed(in webView: WKWebView, coordinator: Coordinator) {
    coordinator.loadedEmbedURL = embedURL

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
          src="\(embedURL.htmlAttributeEscaped)"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          allowfullscreen>
      </iframe>
      </body>
      </html>
      """

    webView.loadHTMLString(html, baseURL: embedURL)
  }

  final class Coordinator: NSObject, WKNavigationDelegate {
    fileprivate var allowedOrigin: WebOrigin
    fileprivate var loadedEmbedURL: URL?

    fileprivate init(allowedOrigin: WebOrigin) {
      self.allowedOrigin = allowedOrigin
    }

    func webView(
      _ webView: WKWebView,
      decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
      guard let url = navigationAction.request.url else {
        return .cancel
      }

      if url.isAboutBlank {
        return .allow
      }

      guard WebOrigin.isSupportedWebURL(url) else {
        return .cancel
      }

      if navigationAction.navigationType == .linkActivated {
        openExternally(url)
        return .cancel
      }

      guard let targetFrame = navigationAction.targetFrame else {
        return .cancel
      }

      if targetFrame.isMainFrame {
        return allowedOrigin.contains(url) ? .allow : .cancel
      }

      return allowedOrigin.contains(url) ? .allow : .cancel
    }

    @MainActor
    private func openExternally(_ url: URL) {
      UIApplication.shared.open(url)
    }
  }
}

private struct WebOrigin {
  let scheme: String
  let host: String
  let port: Int?

  init?(url: URL, allowedHosts: Set<String>? = nil) {
    guard Self.isSupportedWebURL(url),
      let scheme = url.scheme?.lowercased(),
      let host = url.host?.lowercased(),
      !host.isEmpty
    else {
      return nil
    }

    if let allowedHosts {
      let normalizedAllowedHosts = Set(allowedHosts.map { $0.lowercased() })
      guard normalizedAllowedHosts.contains(host) else {
        return nil
      }
    }

    self.scheme = scheme
    self.host = host
    self.port = url.normalizedPort
  }

  static func isSupportedWebURL(_ url: URL) -> Bool {
    guard let scheme = url.scheme?.lowercased() else {
      return false
    }

    return scheme == "http" || scheme == "https"
  }

  func contains(_ url: URL) -> Bool {
    guard let origin = WebOrigin(url: url) else {
      return false
    }

    return origin.scheme == scheme
      && origin.host == host
      && origin.port == port
  }
}

extension URL {
  fileprivate var htmlAttributeEscaped: String {
    absoluteString
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "\"", with: "&quot;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
  }

  fileprivate var isAboutBlank: Bool {
    absoluteString.lowercased() == "about:blank"
  }

  fileprivate var normalizedPort: Int? {
    if let port {
      return port
    }

    switch scheme?.lowercased() {
    case "http":
      return 80
    case "https":
      return 443
    default:
      return nil
    }
  }
}
