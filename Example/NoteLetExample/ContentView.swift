import Notelet
import SwiftUI

struct ContentView: View {

  @State private var presentedVersion: NoteletPresentedVersion?
  @State private var usesExampleSuite = false
  @State private var usesCustomConfiguration = true
  @State private var latestSeenVersion: String?

  private var userDefaults: UserDefaults {
    guard usesExampleSuite else {
      return .standard
    }

    return UserDefaults(suiteName: "com.notelet.example") ?? .standard
  }

  private var configuration: NoteletConfiguration {
    guard usesCustomConfiguration else {
      return .init()
    }

    return .init(
      nextButtonLabel: "Continue",
      doneButtonLabel: "Close",
      accentColor: .orange
    )
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Presentation") {
          Button("Current version") {
            showCurrentVersion()
          }

          Button("Version 2.0") {
            presentedVersion = .v("2.0")
          }
        }

        Section("Configuration") {
          Toggle("Custom labels and tint", isOn: $usesCustomConfiguration)
        }

        Section("Storage") {
          Toggle("Example suite", isOn: $usesExampleSuite)

          LabeledContent("Latest seen", value: latestSeenVersion ?? "None")

          Button("Mark current as seen") {
            NoteletStorage.markCurrentVersionAsSeen(userDefaults: userDefaults)
            refreshLatestSeenVersion()
          }

          Button("Reset seen version", role: .destructive) {
            NoteletStorage.resetSeenVersion(userDefaults: userDefaults)
            refreshLatestSeenVersion()
          }
        }
      }
      .navigationTitle("Notelet Demo")
    }
    .noteletSheet(
      notes: sampleNotes,
      version: presentedVersion,
      onDismiss: {
        presentedVersion = nil
        refreshLatestSeenVersion()
      },
      configuration: configuration,
      userDefaults: userDefaults
    )
    .onAppear(perform: refreshLatestSeenVersion)
    .onChange(of: usesExampleSuite) {
      refreshLatestSeenVersion()
    }
  }

  private func showCurrentVersion() {
    NoteletStorage.resetSeenVersion(userDefaults: userDefaults)
    refreshLatestSeenVersion()
    presentedVersion = .current
  }

  private func refreshLatestSeenVersion() {
    latestSeenVersion = NoteletStorage.getLatestSeenAppVersion(userDefaults: userDefaults)
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
            symbolSystemName: "sparkles",
            title: "SwiftUI sheet",
            description: "Attach release notes to a view with the noteletSheet modifier."
          ),
          .init(
            symbolSystemName: "checkmark.seal.fill",
            title: "Seen state",
            description: "Current-version notes are skipped after the user dismisses them."
          ),
          .init(
            symbolSystemName: "folder.badge.gearshape",
            title: "Storage control",
            description: "Use standard defaults or pass a shared suite for App Group state."
          ),
        ]
      )
    ]
  ),
  NoteletVersionNotes(
    version: "2.0",
    items: [
      .list(
        title: "What's new in 2.0",
        rows: [
          .init(
            symbolSystemName: "paintpalette.fill",
            title: "Configuration",
            description: "Change the next and done labels, plus the accent colour."
          ),
          .init(
            symbolSystemName: "rectangle.stack.fill",
            title: "Paged notes",
            description: "Combine list and media pages in one horizontally paged sheet."
          ),
          .init(
            symbolSystemName: "iphone",
            title: "Adaptive layout",
            description: "The sheet uses compact detents on iPhone and large presentation on iPad."
          ),
        ]
      ),
      .media(
        kind: .image,
        url: URL(string: "https://picsum.photos/seed/notelet/800/800")!,
        title: "Media notes",
        description: "Show an image alongside the text notes for a release."
      ),
    ]
  ),
]

#Preview {
  ContentView()
}
