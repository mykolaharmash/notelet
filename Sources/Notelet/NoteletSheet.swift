//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheet: ViewModifier {
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @State
    private var isPresented = false
    
    @State
    private var resolved: NoteletPresenter.Resolved?

    let notes: [NoteletVersionNotes]
    let version: NoteletPresentedVersion?
    let onDismiss: () -> Void
    let configuration: NoteletConfiguration
    let sheetFractionHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .onAppear {
                resolved = NoteletPresenter.resolve(notes: notes, version: version)
                isPresented = resolved != nil
            }
            .onChange(of: version) {
                resolved = NoteletPresenter.resolve(notes: notes, version: version)
                isPresented = resolved != nil
            }
            .sheet(isPresented: $isPresented, onDismiss: handleDismiss) {
                NoteletSheetContentView(
                    versionNotes: resolved?.versionNotes ?? [],
                    configuration: configuration
                )
                .presentationDetents([
                    isIPad ? .large : .fraction(sheetFractionHeight)
                ])
                .presentationDragIndicator(.visible)
                .presentationBackground(sheetBackgroundStyle)
            }
    }
}

private extension NoteletSheet {
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var sheetBackgroundStyle: AnyShapeStyle {
        if #available(iOS 26, *) {
            let color: Color = colorScheme == .dark ? .black : .white
            return AnyShapeStyle(color.opacity(0.55))
        }
        return AnyShapeStyle(.regularMaterial)
    }

    func handleDismiss() {
        if resolved?.isCurrentVersionMode == true {
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
        configuration: NoteletConfiguration = .init(),
        sheetFractionHeight: CGFloat = 0.85
    ) -> some View {
        modifier(
            NoteletSheet(
                notes: notes,
                version: version,
                onDismiss: onDismiss,
                configuration: configuration,
                sheetFractionHeight: sheetFractionHeight
            )
        )
    }
}
