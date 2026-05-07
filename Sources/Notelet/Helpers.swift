//
//  Helpers.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import Foundation

final class Helpers {
    static func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
    
    static func getVersionNotes(for version: String, in notes: [NoteletVersionNotes]) -> [NoteletVersionNoteItem] {
        return notes.first(where: { $0.version == version })?.items ?? []
    }

}
