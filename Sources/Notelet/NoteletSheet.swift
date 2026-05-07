//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheet: ViewModifier {

    let notes: [NoteletVersionNotes]
    let item: Binding<NoteletSheetItem?>
    let onDismiss: () -> Void
    let configuration: NoteletConfiguration

    private var presentableItem: Binding<NoteletSheetItem?> {
        Binding(
            get: {
                guard let item = item.wrappedValue, shouldPresent(item) else {
                    return nil
                }

                return item
            },
            set: { newValue in
                item.wrappedValue = newValue
            }
        )
    }

    private func shouldPresent(_ item: NoteletSheetItem) -> Bool {
        guard !Helpers.getVersionNotes(for: item, in: notes).isEmpty else {
            return false
        }

        switch item {
        case .currentVersion:
            let version = Helpers.getCurrentAppVersion()
            
            let latestSeenVersion = UserDefaults.standard.string(
                forKey: NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY
            )
            
            return latestSeenVersion != version
        case .specificVersion:
            return true
        }
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(item: presentableItem, onDismiss: onDismiss) { item in
                NoteletSheetContentView(
                    notes: notes,
                    sheetItem: item,
                    configuration: configuration
                )
            }
    }
}

extension View {
    public func noteletSheet(
        notes: [NoteletVersionNotes],
        item: Binding<NoteletSheetItem?>,
        onDismiss: @escaping () -> Void = { },
        configuration: NoteletConfiguration = .init()
    ) -> some View {
        modifier(
            NoteletSheet(
                notes: notes,
                item: item,
                onDismiss: onDismiss,
                configuration: configuration
            )
        )
    }
}
