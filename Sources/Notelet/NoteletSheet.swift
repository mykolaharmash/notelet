//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheet: ViewModifier {

    @State private var isPresented = false
    @State private var activePresentation: NoteletPresenter.Presentation?

    let notes: [NoteletVersionNotes]
    let version: NoteletPresentedVersion?
    let onDismiss: () -> Void
    let configuration: NoteletConfiguration
    let userDefaults: UserDefaults

    private var versionNotes: [NoteletVersionNoteItem] {
        activePresentation?.versionNotes ?? []
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                updatePresentation()
            }
            .onChange(of: version) {
                updatePresentation()
            }
            .sheet(isPresented: $isPresented, onDismiss: handleDismiss) {
                NoteletSheetContentView(
                    versionNotes: versionNotes,
                    configuration: configuration
                )
            }
    }
}

private extension NoteletSheet {

    func updatePresentation() {
        activePresentation = NoteletPresenter.presentation(
            notes: notes,
            version: version,
            userDefaults: userDefaults
        )
        isPresented = activePresentation != nil
    }

    func handleDismiss() {
        if activePresentation?.isCurrentVersionMode == true {
            NoteletStorage.markCurrentVersionAsSeen(userDefaults: userDefaults)
        }

        onDismiss()
    }
}

extension View {
    /// Attach a release-notes sheet to the modified view.
    ///
    /// - Parameter userDefaults: Storage backing the "seen version" check used
    ///   in `.current` presentation mode. Defaults to `.standard`. Pass an App
    ///   Group `UserDefaults` (e.g. `UserDefaults(suiteName: "group.com.example.myapp")`)
    ///   when the host app needs to share "seen" state with an extension
    ///   target like a widget, intent, or share extension.
    public func noteletSheet(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion? = nil,
        onDismiss: @escaping () -> Void = { },
        configuration: NoteletConfiguration = .init(),
        userDefaults: UserDefaults = .standard
    ) -> some View {
        modifier(
            NoteletSheet(
                notes: notes,
                version: version,
                onDismiss: onDismiss,
                configuration: configuration,
                userDefaults: userDefaults
            )
        )
    }
}
