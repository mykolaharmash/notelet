//
//  File.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct MediaNoteItemDetailsView: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.bold))
            Text(description)

        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
        .foregroundStyle(.primary)
    }
}
