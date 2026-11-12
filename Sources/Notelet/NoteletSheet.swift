//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheet: ViewModifier {
    @State private var isPresented = false

    let notes: [NoteletVersionNotes]
    let version: NoteletPresentedVersion?
    let onDismiss: () -> Void
    let nextButtonLabel: LocalizedStringResource
    let doneButtonLabel: LocalizedStringResource
    let accentColor: Color
    let presentationDetents: Set<PresentationDetent>?
    let userDefaults: UserDefaults

    private var versionToShow: String? {
        switch version {
        case .current:
            Helpers.getCurrentAppVersion()
        case .v(let providedVersion):
            providedVersion
        case nil:
            nil
        }
    }

    private var versionNotes: [NoteletVersionNoteItem] {
        guard let versionToShow else {
            return []
        }

        return Helpers.getVersionNotes(for: versionToShow, in: notes)
    }

    private var isCurrentVersionMode: Bool {
        if case .current = version {
            return true
        }

        return false
    }

    private var isCurrentVersionAlreadySeen: Bool {
        userDefaults.string(
            forKey: NoteletStorageKey.latestSeenAppVersion
        ) == Helpers.getCurrentAppVersion()
    }

    private var shouldPresent: Bool {
        guard version != nil else {
            return false
        }

        guard !versionNotes.isEmpty else {
            return false
        }

        if isCurrentVersionMode {
            return !isCurrentVersionAlreadySeen
        }

        return true
    }

    
    func body(content: Content) -> some View {
        content
            .onAppear {
                isPresented = shouldPresent
            }
            .onChange(of: version) {
                isPresented = shouldPresent
            }
            .sheet(isPresented: $isPresented, onDismiss: handleDismiss) {
                NoteletSheetContentView(
                    versionNotes: versionNotes,
                    nextButtonLabel: nextButtonLabel,
                    doneButtonLabel: doneButtonLabel,
                    accentColor: accentColor,
                    presentationDetents: presentationDetents
                )
            }
    }
    
    private func handleDismiss() {
        if isCurrentVersionMode {
            NoteletStorage.markCurrentVersionAsSeen(userDefaults: userDefaults)
        }

        onDismiss()
    }
}

extension View {
    /// Attach a release-notes sheet to the modified view.
    ///
    /// - Parameters:
    ///   - notes: Release notes grouped by app version.
    ///   - version: The app version to present. Pass `nil` to keep the sheet hidden.
    ///   - onDismiss: Called when the sheet is dismissed.
    ///   - nextButtonLabel: Localized accessibility label for the arrow button.
    ///   - doneButtonLabel: Localized accessibility label for the checkmark button.
    ///   - accentColor: Tint for the action button and list symbols.
    ///   - presentationDetents: A nonempty set that replaces the default detents.
    ///     Pass `nil` to use `[.fraction(0.85), .large]`.
    ///   - userDefaults: Storage backing the "seen version" check used in `.current`
    ///     presentation mode. Defaults to `.standard`. Pass an App Group
    ///     `UserDefaults` to share "seen" state with an extension.
    public func noteletSheet(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion? = nil,
        onDismiss: @escaping () -> Void = { },
        nextButtonLabel: LocalizedStringResource = "Next",
        doneButtonLabel: LocalizedStringResource = "Done",
        accentColor: Color = .blue,
        presentationDetents: Set<PresentationDetent>? = nil,
        userDefaults: UserDefaults = .standard
    ) -> some View {
        modifier(
            NoteletSheet(
                notes: notes,
                version: version,
                onDismiss: onDismiss,
                nextButtonLabel: nextButtonLabel,
                doneButtonLabel: doneButtonLabel,
                accentColor: accentColor,
                presentationDetents: presentationDetents,
                userDefaults: userDefaults
            )
        )
    }
}
