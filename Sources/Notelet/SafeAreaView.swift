//
//  SafeAreaView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct SafeAreaView<SafeAreaContent: View>: ViewModifier {
    @ViewBuilder var safeAreaContent: () -> SafeAreaContent
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .safeAreaBar(edge: .bottom) {
                    safeAreaContent()
                }
        } else {
            content
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    safeAreaContent()
                        .frame(maxWidth: .infinity)
                        .background {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea(edges: .bottom)
                        }
                }
        }
    }
}
