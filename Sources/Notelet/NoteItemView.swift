//
//  NoteItemView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteItemView: View {
    let item: NoteletVersionNoteItem
    let isCurrent: Bool
    let configuration: NoteletConfiguration
    
    @State private var containerSize: CGSize = .zero
    
    private var clipShapeRadius: Double {
        if #available(iOS 26, *) {
            24
        } else {
            12
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch item {
            case .media(let mediaKind, let url, let title, let description):
                VStack(alignment: .center, spacing: 12) {
                    let mediaPadding = 16.0
                    /**
                     * 440 points is the largets iPhone width right now.
                     * Clamping to that width so the media fits perfectly on
                     * any iPhone and don't streatch to the full width on
                     * iPads and iPhones in landscape orientation.
                     */
                    let containerWidth = min(max(containerSize.width, 300), 440)
                    
                    ZStack {
                        switch mediaKind {
                        case .image:
                            MediaNoteItemImageView(
                                imageUrl: url
                            )
                        case .video:
                            MediaNoteItemVideoView(
                                videoURL: url,
                                isPlaying: isCurrent
                            )
                        }
                    }
                    .frame(
                        width: containerWidth - mediaPadding * 2,
                        height: containerWidth - mediaPadding * 2
                    )
                    .clipShape(.rect(cornerRadius: clipShapeRadius))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 0)
                    .padding(mediaPadding)
                    .accessibilityLabel(Text(title))
                    
                    MediaNoteItemDetailsView(
                        title: title,
                        description: description
                    )
                    
                    Spacer()
                }
            case .list(let title, let rows):
                BulletListNoteItemView(
                    title: title,
                    rows: rows,
                    accentColor: configuration.accentColor
                )
            }
        }
        .containerRelativeFrame(.horizontal, alignment: .center)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            containerSize = newSize
        }
    }
}
