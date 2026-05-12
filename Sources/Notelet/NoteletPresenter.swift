//
//  NoteletPresenter.swift
//  Notelet
//

import Foundation

enum NoteletPresenter {

    struct Presentation: Sendable {
        let versionNotes: [NoteletVersionNoteItem]
        let isCurrentVersionMode: Bool
    }

    static func presentation(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion?,
        userDefaults: UserDefaults = .standard
    ) -> Presentation? {
        guard let version else { return nil }

        let versionString: String
        let isCurrentVersionMode: Bool

        switch version {
        case .current:
            versionString = Helpers.getCurrentAppVersion()
            isCurrentVersionMode = true
        case .v(let provided):
            versionString = provided
            isCurrentVersionMode = false
        }

        if isCurrentVersionMode {
            let latestSeen = NoteletStorage.getLatestSeenAppVersion(userDefaults: userDefaults)
            guard versionString != latestSeen else { return nil }
        }

        let noteItems = Helpers.getVersionNotes(for: versionString, in: notes)
        guard !noteItems.isEmpty else { return nil }

        return Presentation(versionNotes: noteItems, isCurrentVersionMode: isCurrentVersionMode)
    }
}
