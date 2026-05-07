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

public enum NoteletSheetItem: Hashable, Identifiable {
    public var id: String {
        switch self {
        case .currentVersion:
            Helpers.getCurrentAppVersion()
        case .specificVersion(let version):
            version
        }
    }
    
    case currentVersion
    case specificVersion(String)
}

public struct NoteletConfiguration {
    let nextButtonLabel: LocalizedStringResource
    let doneButtonLabel: LocalizedStringResource
    let accentColor: Color
    
    public init(
        nextButtonLabel: LocalizedStringResource = "Next",
        doneButtonLabel: LocalizedStringResource = "Done",
        accentColor: Color = .blue
    ) {
        self.nextButtonLabel = nextButtonLabel
        self.doneButtonLabel = doneButtonLabel
        self.accentColor = accentColor
    }
}
