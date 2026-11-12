import SwiftUI

// Keep the footer outside NavigationStack so the pager's native scroll edge effect includes it.
struct NoteletSheetContainer<Content: View, ActionButton: View>: View {
    let pageCount: Int
    let currentPage: Int
    let actionButton: ActionButton
    @ViewBuilder var content: () -> Content

    var body: some View {
        #if os(macOS)
        content()
            .modifier(
                SafeAreaView {
                    NoteletSheetFooter(
                        pageCount: pageCount,
                        currentPage: currentPage,
                        showsAction: true,
                        actionButton: actionButton
                    )
                }
            )
        #else
        if #available(iOS 27.1, *) {
            VerticalNoteletSheetContainer(
                pageCount: pageCount,
                currentPage: currentPage,
                actionButton: actionButton,
                content: content()
            )
        } else {
            NavigationStack {
                content()
            }
            .modifier(
                SafeAreaView {
                    NoteletSheetFooter(
                        pageCount: pageCount,
                        currentPage: currentPage,
                        showsAction: true,
                        actionButton: actionButton
                    )
                }
            )
            .ignoresSafeArea(.container, edges: .bottom)
        }
        #endif
    }
}

#if os(iOS)
@available(iOS 27.1, *)
private struct VerticalNoteletSheetContainer<Content: View, ActionButton: View>: View {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge

    let pageCount: Int
    let currentPage: Int
    let actionButton: ActionButton
    let content: Content

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    if toolbarVerticalEdge != nil && pageCount > 0 {
                        ToolbarItem(placement: .bottomBar) {
                            actionButton
                        }
                        .axisBehavior(.verticalPreferred)
                    }
                }
        }
        .modifier(
            SafeAreaView {
                NoteletSheetFooter(
                    pageCount: pageCount,
                    currentPage: currentPage,
                    showsAction: toolbarVerticalEdge == nil,
                    actionButton: actionButton
                )
            }
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
#endif

private struct NoteletSheetFooter<ActionButton: View>: View {
    let pageCount: Int
    let currentPage: Int
    let showsAction: Bool
    let actionButton: ActionButton

    var body: some View {
        if pageCount > 1 || (showsAction && pageCount > 0) {
            ZStack {
                if pageCount > 1 {
                    NoteletPageIndicator(pageCount: pageCount, currentPage: currentPage)
                        .frame(maxWidth: .infinity)
                        // Center across the sheet, independently of the action and side toolbar.
                        .ignoresSafeArea(.container, edges: .horizontal)
                        .allowsHitTesting(false)
                }

                HStack {
                    Spacer(minLength: 0)
                    if showsAction {
                        actionButton
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
}

private struct NoteletPageIndicator: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        let accessibilityLabel: LocalizedStringResource = "Page \(currentPage + 1) of \(pageCount)"

        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                /**
                 * Use symbols instead of Circle views because
                 * iOS 27 did not consider Circle for the scroll edge
                 * effect didn't extent the blur to the full safe area
                 * height
                 */
                Image(systemName: "circle.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.primary.opacity(index == currentPage ? 0.65 : 0.2))
                    .frame(width: 7, height: 7)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityLabel))
        .animation(.easeInOut(duration: 0.2), value: currentPage)
    }
}

struct NoteletCircularActionButton: View {
    let title: LocalizedStringResource
    let systemImage: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
            }
            .labelStyle(.iconOnly)
            .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .tint(accentColor)
        #if os(macOS)
        .keyboardShortcut(.defaultAction)
        #endif
    }
}
