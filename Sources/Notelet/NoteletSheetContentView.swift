//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheetContentView: View {
    let versionNotes: [NoteletVersionNoteItem]
    let nextButtonLabel: LocalizedStringResource
    let doneButtonLabel: LocalizedStringResource
    let accentColor: Color
    let presentationDetents: Set<PresentationDetent>?

    @State private var selectedPageID: Int? = 0

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var currentPage: Int {
        return selectedPageID ?? 0
    }

    private var sheetBackgroundStyle: AnyShapeStyle {
        if #available(iOS 26, macOS 26, *) {
            let color: Color = colorScheme == .dark ? .black : .white

            return AnyShapeStyle(color.opacity(0.55))
        }

        return AnyShapeStyle(.regularMaterial)
    }

    var body: some View {
        let isOnLastPage = isOnLastPage(versionNotes: versionNotes, currentPage: currentPage)
        let buttonTitle = isOnLastPage ? doneButtonLabel : nextButtonLabel

        NoteletSheetContainer(
            pageCount: versionNotes.count,
            currentPage: currentPage,
            actionButton: NoteletCircularActionButton(
                title: buttonTitle,
                systemImage: isOnLastPage ? "checkmark" : "arrow.forward",
                accentColor: accentColor,
                action: onAdvanceTap
            )
        ) {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(versionNotes.enumerated()), id: \.offset) { index, item in
                                ScrollView(.vertical) {
                                    NoteItemView(
                                        item: item,
                                        isCurrent: index == currentPage,
                                        availableWidth: geometry.size.width,
                                        accentColor: accentColor
                                    )
                                }
                                .contentMargins(.bottom, 80)
                                .frame(width: geometry.size.width)
                                .opacity(index == currentPage ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                                .id(index)
                            }
                        }
                        .scrollTargetLayout()
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.width
                        } action: { width in
                            guard width > 0 else { return }
                            // Realign after the pages, rather than just the viewport, finish resizing.
                            scrollProxy.scrollTo(currentPage, anchor: .leading)
                        }
                    }
                    // Align to the safe-area-sized page rather than the full scroll container.
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .scrollIndicators(.hidden)
                    .scrollPosition(id: $selectedPageID, anchor: .leading)
                    .modifier(SoftScrollEdgeEffect())
                }
            }
        }
        #if os(macOS)
        .modifier(MacOSNoteletSheetSizing())
        .frame(
            minWidth: 360, idealWidth: 480, maxWidth: .infinity,
            minHeight: 400, idealHeight: 640, maxHeight: .infinity
        )
        .onExitCommand { dismiss() }
        #else
        .presentationDetents(presentationDetents ?? [.fraction(0.85), .large])
        .presentationDragIndicator(.visible)
        #endif
        .presentationBackground(sheetBackgroundStyle)
    }

    private func onAdvanceTap() {
        if isOnLastPage(versionNotes: versionNotes, currentPage: currentPage) {
            dismiss()
        } else {
            withAnimation(.smooth) {
                selectedPageID = min(currentPage + 1, versionNotes.count - 1)
            }
        }
    }

    private func isOnLastPage(versionNotes: [NoteletVersionNoteItem], currentPage: Int) -> Bool {
        guard !versionNotes.isEmpty else {
            return true
        }

        return currentPage >= versionNotes.count - 1
    }
}

#if os(macOS)
private struct MacOSNoteletSheetSizing: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15, *) {
            content.presentationSizing(.fitted)
        } else {
            content
        }
    }
}
#endif

fileprivate struct SoftScrollEdgeEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content
                .scrollEdgeEffectStyle(.soft, for: .all)
        } else {
            content
        }
    }
}
