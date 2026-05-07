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
    let configuration: NoteletConfiguration

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
        UserDefaults.standard.string(
            forKey: NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY
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
                    configuration: configuration
                )
            }
    }
    
    private func handleDismiss() {
        if isCurrentVersionMode {
            NoteletStorage.markCurrentVersionAsSeen()
        }
        
        onDismiss()
    }
}

extension View {
    public func noteletSheet(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion? = nil,
        onDismiss: @escaping () -> Void = { },
        configuration: NoteletConfiguration = .init()
    ) -> some View {
        modifier(
            NoteletSheet(
                notes: notes,
                version: version,
                onDismiss: onDismiss,
                configuration: configuration
            )
        )
    }
}
