//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheetContentView: View {
    let versionNotes: [NoteletVersionNoteItem]
    let configuration: NoteletConfiguration

    @State private var selectedPageID: Int? = 0

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var currentPage: Int {
        return selectedPageID ?? 0
    }

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var sheetBackgroundStyle: AnyShapeStyle {
        if #available(iOS 26, *) {
            let color: Color = colorScheme == .dark ? .black : .white

            return AnyShapeStyle(color.opacity(0.55))
        }

        return AnyShapeStyle(.regularMaterial)
    }

    var body: some View {
        let isOnLastPage = isOnLastPage(versionNotes: versionNotes, currentPage: currentPage)
        let buttonTitle = isOnLastPage ? configuration.doneButtonLabel : configuration.nextButtonLabel

        NoteletSheetContainer(
            pageCount: versionNotes.count,
            currentPage: currentPage,
            actionButton: NoteletCircularActionButton(
                title: buttonTitle,
                systemImage: isOnLastPage ? "checkmark" : "arrow.forward",
                accentColor: configuration.accentColor,
                action: onAdvanceTap
            )
        ) {
            GeometryReader { geometry in
                let _ = print(geometry.size.width)
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(versionNotes.enumerated()), id: \.offset) { index, item in
                                ScrollView(.vertical) {
                                    NoteItemView(
                                        item: item,
                                        isCurrent: index == currentPage,
                                        availableWidth: geometry.size.width,
                                        configuration: configuration
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
        .presentationDetents([
            isIPad || configuration.sheetHeight == .full ? .large : .fraction(0.85)
        ])
        .presentationDragIndicator(.visible)
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

fileprivate struct SoftScrollEdgeEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .scrollEdgeEffectStyle(.soft, for: .all)
        } else {
            content
        }
    }
}
