//
//  NoteletPresenter.swift
//  Notelet
//

import Foundation

enum NoteletPresenter {

    struct Resolved: Sendable {
        let versionNotes: [NoteletVersionNoteItem]
        let isCurrentVersionMode: Bool
    }

    static func resolve(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion?
    ) -> Resolved? {
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
            let latestSeen = UserDefaults.standard.string(
                forKey: NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY
            )
            guard versionString != latestSeen else { return nil }
        }

        let noteItems = Helpers.getVersionNotes(for: versionString, in: notes)
        guard !noteItems.isEmpty else { return nil }

        return Resolved(versionNotes: noteItems, isCurrentVersionMode: isCurrentVersionMode)
    }
}
