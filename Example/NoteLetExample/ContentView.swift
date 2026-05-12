import SwiftUI
import Notelet

struct ContentView: View {

    @State private var swiftUIVersion: NoteletPresentedVersion? = nil
    @State private var showUIKitDemo = false

    var body: some View {
        NavigationStack {
            List {
                Section("SwiftUI") {
                    Button("Show release notes (.current)") {
                        NoteletStorage.resetSeenVersion()
                        swiftUIVersion = .current
                    }

                    Button("Show release notes (v2.0)") {
                        swiftUIVersion = .v("2.0")
                    }

                    Button("Show release notes (v3.0 - embed video)") {
                        swiftUIVersion = .v("3.0")
                    }
                }

                Section("UIKit") {
                    Button("Present via UIViewController") {
                        showUIKitDemo = true
                    }
                }

                Section {
                    Button("Reset seen version", role: .destructive) {
                        NoteletStorage.resetSeenVersion()
                    }
                }
            }
            .navigationTitle("Notelet Demo")
        }
        .noteletSheet(notes: sampleNotes, version: swiftUIVersion) {
            swiftUIVersion = nil
        }
        .sheet(isPresented: $showUIKitDemo) {
            UIKitDemoView()
        }
    }
}

// MARK: - UIKit demo wrapper

private struct UIKitDemoView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitDemoViewController {
        UIKitDemoViewController()
    }
    func updateUIViewController(_ uiViewController: UIKitDemoViewController, context: Context) {}
}

final class UIKitDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "UIKit host"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        let button = UIButton(configuration: .filled())
        button.setTitle("Present Notelet sheet", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showNotelet), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
        ])
    }

    @objc private func showNotelet() {
        presentNoteletSheet(notes: sampleNotes, version: .v("2.0"))
    }
}

// MARK: - Sample data

let sampleNotes: [NoteletVersionNotes] = [
    NoteletVersionNotes(
        version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        items: [
            .list(
                title: "What's new in 1.0",
                rows: [
                    .init(
                        symbolSystemName: "star.fill",
                        title: "Release notes",
                        description: "Beautiful paginated release notes right in your app."
                    ),
                    .init(
                        symbolSystemName: "paintbrush.fill",
                        title: "Fully customisable",
                        description: "Accent colours, button labels, and sheet height are all configurable."
                    ),
                    .init(
                        symbolSystemName: "arrow.trianglehead.2.clockwise",
                        title: "Smart display logic",
                        description: "Shows only when the user hasn't seen this version yet."
                    ),
                ]
            ),
        ]
    ),
    NoteletVersionNotes(
        version: "2.0",
        items: [
            .list(
                title: "What's new in 2.0",
                rows: [
                    .init(
                        symbolSystemName: "uiwindow.split.2x1",
                        title: "UIKit support",
                        description: "Call presentNoteletSheet() directly on any UIViewController."
                    ),
                    .init(
                        symbolSystemName: "iphone",
                        title: "Adaptive height",
                        description: "Control the sheet fraction height, or go full-screen on iPad."
                    ),
                    .init(
                        symbolSystemName: "accessibility",
                        title: "Accessibility",
                        description: "Improved VoiceOver support across all note types."
                    ),
                ]
            ),
            .media(
                kind: .image,
                url: URL(string: "https://picsum.photos/seed/notelet/800/800")!,
                title: "Beautiful media",
                description: "Show an image alongside your release notes."
            ),
        ]
    ),
    NoteletVersionNotes(
        version: "3.0",
        items: [
            .list(
                title: "What's new in 3.0",
                rows: [
                    .init(
                        symbolSystemName: "play.rectangle.fill",
                        title: "Embed videos",
                        description: "YouTube and Vimeo embeds now supported natively."
                    ),
                ]
            ),
            .media(
                kind: .embed,
                url: URL(string: "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ")!,
                title: "YouTube embed",
                description: "Loaded via youtube-nocookie.com for fewer tracking restrictions."
            ),
            .media(
                kind: .embed,
                url: URL(string: "https://player.vimeo.com/video/76979871")!,
                title: "Vimeo embed",
                description: "The Mountain - a timelapse film by Terje Sorgjerd."
            ),
        ]
    ),
]

#Preview {
    ContentView()
}
