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

    static func getVersionNotes(for sheetItem: NoteletSheetItem, in notes: [NoteletVersionNotes]) -> [NoteletVersionNoteItem] {
        switch sheetItem {
        case .currentVersion:
            return getVersionNotes(for: getCurrentAppVersion(), in: notes)
        case .specificVersion(let version):
            return getVersionNotes(for: version, in: notes)
        }
    }
}
