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
    let availableWidth: CGFloat
    let configuration: NoteletConfiguration

    @State private var mediaLoadState: MediaNoteItemLoadState = .loading

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
                    let mediaPadding: CGFloat = 16
                    // Cap media on wide layouts while allowing it to shrink with the page.
                    let mediaSize = max(0, min(availableWidth, 440) - mediaPadding * 2)

                    ZStack {
                        switch mediaKind {
                        case .image:
                            MediaNoteItemImageView(
                                imageUrl: url,
                                onLoadStateChange: { mediaLoadState = $0 }
                            )
                        case .video:
                            MediaNoteItemVideoView(
                                videoURL: url,
                                isPlaying: isCurrent,
                                onLoadStateChange: { mediaLoadState = $0 }
                            )
                        }
                    }
                    .frame(
                        width: mediaSize,
                        height: mediaSize
                    )
                    .clipShape(.rect(cornerRadius: clipShapeRadius))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(mediaPadding)

                    MediaNoteItemDetailsView(
                        title: title,
                        description: description
                    )

                    Spacer()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    mediaAccessibilityLabel(
                        kind: mediaKind,
                        loadState: mediaLoadState,
                        title: title,
                        description: description
                    )
                )
            case .list(let title, let rows):
                BulletListNoteItemView(
                    title: title,
                    rows: rows,
                    accentColor: configuration.accentColor
                )
            }
        }
    }

    private func mediaAccessibilityLabel(
        kind: NoteletVersionNoteItem.MediaKind,
        loadState: MediaNoteItemLoadState,
        title: LocalizedStringResource,
        description: LocalizedStringResource
    ) -> Text {
        switch (kind, loadState) {
        case (.image, .loading):
            Text("Loading image. \(title). \(description)")
        case (.image, .loaded):
            Text("Image. \(title). \(description)")
        case (.image, .failed):
            Text("Image failed to load. \(title). \(description)")
        case (.video, .loading):
            Text("Loading video. \(title). \(description)")
        case (.video, .loaded):
            Text("Video. \(title). \(description)")
        case (.video, .failed):
            Text("Video failed to load. \(title). \(description)")
        }
    }
}
