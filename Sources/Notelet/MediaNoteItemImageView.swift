//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct MediaNoteItemImageView: View {
    let imageUrl: URL
    let onLoadStateChange: (MediaNoteItemLoadState) -> Void

    var body: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .onAppear {
                        onLoadStateChange(.loading)
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .onAppear {
                        onLoadStateChange(.loaded)
                    }
            case .failure:
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .onAppear {
                        onLoadStateChange(.failed)
                    }
            @unknown default:
                ProgressView()
                    .onAppear {
                        onLoadStateChange(.loading)
                    }
            }
        }
    }
}
