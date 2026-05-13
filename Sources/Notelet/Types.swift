//
//  types.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import Foundation
import SwiftUI
import UIKit

public enum NoteletVersionNoteItem: Sendable, Codable {
  case media(
    kind: MediaKind, url: URL, title: LocalizedStringResource, description: LocalizedStringResource)
  case list(title: LocalizedStringResource, rows: [ListRow])

  public enum MediaKind: Sendable, Codable {
    case image
    case video
    /// An embeddable web player URL, such as a YouTube or Vimeo embed URL.
    case embed
  }

  public struct ListRow: Sendable, Codable {
    public init(
      symbolSystemName: String, title: LocalizedStringResource, description: LocalizedStringResource
    ) {
      self.symbolSystemName = symbolSystemName
      self.title = title
      self.description = description
    }

    let symbolSystemName: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource
  }
}

public struct NoteletVersionNotes: Sendable, Codable {
  public init(version: String, items: [NoteletVersionNoteItem]) {
    self.version = version
    self.items = items
  }

  let version: String
  let items: [NoteletVersionNoteItem]
}

public enum NoteletPresentedVersion: Sendable, Hashable {
  case current
  case v(String)
}

public struct NoteletConfiguration: Sendable {
  /// Common third-party hosts used by web embeds.
  public static let commonEmbedHosts: Set<String> = [
    "player.vimeo.com",
    "www.youtube-nocookie.com",
  ]

  let nextButtonLabel: LocalizedStringResource
  let doneButtonLabel: LocalizedStringResource
  /// Uses `UIColor` so the same configuration works from SwiftUI and UIKit.
  let accentColor: UIColor
  let allowedEmbedHosts: Set<String>

  public init(
    nextButtonLabel: LocalizedStringResource = "Next",
    doneButtonLabel: LocalizedStringResource = "Done",
    accentColor: UIColor = .tintColor,
    allowedEmbedHosts: Set<String> = []
  ) {
    self.nextButtonLabel = nextButtonLabel
    self.doneButtonLabel = doneButtonLabel
    self.accentColor = accentColor
    self.allowedEmbedHosts = allowedEmbedHosts
  }
}
