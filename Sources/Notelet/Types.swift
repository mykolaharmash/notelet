//
//  types.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import Foundation
import SwiftUI

public enum NoteletVersionNoteItem: Sendable, Codable {
    case media(kind: MediaKind, url: URL, title: LocalizedStringResource, description: LocalizedStringResource)
    case list(title: LocalizedStringResource, rows: [ListRow])
    
    public enum MediaKind: Sendable, Codable {
        case image
        case video
    }
    
    public struct ListRow: Sendable, Codable {
        public init(symbolSystemName: String, title: LocalizedStringResource, description: LocalizedStringResource) {
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
    let nextButtonLabel: LocalizedStringResource
    let doneButtonLabel: LocalizedStringResource
    let accentColor: Color
    let presentationDetents: Set<PresentationDetent>?

    /// Customize the release-notes sheet.
    ///
    /// - Parameters:
    ///   - nextButtonLabel: Localized accessibility label for the arrow button.
    ///   - doneButtonLabel: Localized accessibility label for the checkmark button.
    ///   - accentColor: Tint for the action button and list symbols.
    ///   - presentationDetents: A nonempty set that replaces the default detents
    ///     on iOS and iPadOS. Pass `nil` to use `[.fraction(0.85), .large]`.
    ///     macOS uses native sheet sizing instead.
    public init(
        nextButtonLabel: LocalizedStringResource = "Next",
        doneButtonLabel: LocalizedStringResource = "Done",
        accentColor: Color = .blue,
        presentationDetents: Set<PresentationDetent>? = nil
    ) {
        self.nextButtonLabel = nextButtonLabel
        self.doneButtonLabel = doneButtonLabel
        self.accentColor = accentColor
        self.presentationDetents = presentationDetents
    }
}
