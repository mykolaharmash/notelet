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

    private var currentPage: Int {
        return selectedPageID ?? 0
    }
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        let isOnLastPage = isOnLastPage(versionNotes: versionNotes, currentPage: currentPage)
        
        NavigationStack {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(versionNotes.enumerated()), id: \.offset) { index, item in
                        ScrollView(.vertical) {
                            NoteItemView(
                                item: item,
                                isCurrent: index == currentPage,
                                configuration: configuration
                            )
                            .id(index)
                        }
                        .contentMargins(.bottom, 80)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $selectedPageID)
        }
        .modifier(
            SafeAreaView {
                VStack(spacing: 16) {
                    if versionNotes.count > 1 {
                        let selectedIndicatorColor = colorScheme == .light ? Color.black : Color.white
                        
                        HStack(spacing: 6) {
                            ForEach(versionNotes.indices, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? selectedIndicatorColor.opacity(0.35) : Color.secondary.opacity(0.35))
                                    .frame(width: index == currentPage ? 14 : 7, height: 7)
                                    .accessibilityLabel(index == currentPage ? "Page \(index + 1) of \(versionNotes.count), current" : "Page \(index + 1) of \(versionNotes.count)")
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Page \(currentPage + 1) of \(versionNotes.count)")
                        .padding(.top, 14)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                    
                    if !versionNotes.isEmpty {
                        Button {
                            if isOnLastPage {
                                onDoneTap()
                            } else {
                                withAnimation(.smooth) {
                                    selectedPageID = min(currentPage + 1, versionNotes.count - 1)
                                }
                            }
                        } label: {
                            let buttonTitle: LocalizedStringResource = isOnLastPage
                            ? configuration.doneButtonLabel
                            : configuration.nextButtonLabel
                            
                            Text(buttonTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 28)
                        .tint(Color(configuration.accentColor))
                    }
                }
                .safeAreaPadding(.bottom, isIPad ? 24 : 0)
            }
        )
    }
    
    private func onDoneTap() {
        dismiss()
    }
    
    private func isOnLastPage(versionNotes: [NoteletVersionNoteItem], currentPage: Int) -> Bool {
        guard !versionNotes.isEmpty else {
            return true
        }

        return currentPage >= versionNotes.count - 1
    }
}
