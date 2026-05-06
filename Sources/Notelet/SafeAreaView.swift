//
//  SafeAreaView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct SafeAreaView<SafeAreContent: View>: ViewModifier {
    @ViewBuilder var safeAreContent: () -> SafeAreContent
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .safeAreaBar(edge: .bottom) {
                    safeAreContent()
                }
        } else {
            content
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    safeAreContent()
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
