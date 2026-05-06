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
    
    func body(content: Content) -> some View {
        content
            .sheet(item: item, onDismiss: onDismiss) { item in
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

