//
//  SwiftUIView.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

import SwiftUI

struct NoteletSheet: ViewModifier {

  @State private var activePresentation: NoteletPresenter.Presentation?
  @State private var dismissedPresentation: NoteletPresenter.Presentation?

  let notes: [NoteletVersionNotes]
  let version: NoteletPresentedVersion?
  let onDismiss: () -> Void
  let configuration: NoteletConfiguration
  let userDefaults: UserDefaults

  func body(content: Content) -> some View {
    content
      .onAppear {
        updatePresentation()
      }
      .onChange(of: version) {
        updatePresentation()
      }
      .sheet(item: activePresentationBinding, onDismiss: handleDismiss) { presentation in
        NoteletSheetContentView(
          versionNotes: presentation.versionNotes,
          configuration: configuration
        )
      }
  }
}

extension NoteletSheet {

  fileprivate var activePresentationBinding: Binding<NoteletPresenter.Presentation?> {
    Binding {
      activePresentation
    } set: { newValue in
      if newValue == nil {
        dismissedPresentation = activePresentation
      }

      activePresentation = newValue
    }
  }

  fileprivate func updatePresentation() {
    activePresentation = NoteletPresenter.presentation(
      notes: notes,
      version: version,
      userDefaults: userDefaults
    )
  }

  fileprivate func handleDismiss() {
    if dismissedPresentation?.isCurrentVersionMode == true {
      NoteletStorage.markCurrentVersionAsSeen(userDefaults: userDefaults)
    }

    dismissedPresentation = nil
    onDismiss()
  }
}

extension View {
  /// Attach a release-notes sheet to the modified view.
  ///
  /// - Parameter userDefaults: Storage backing the "seen version" check used
  ///   in `.current` presentation mode. Defaults to `.standard`. Pass an App
  ///   Group `UserDefaults` (e.g. `UserDefaults(suiteName: "group.com.example.myapp")`)
  ///   when the host app needs to share "seen" state with an extension
  ///   target like a widget, intent, or share extension.
  public func noteletSheet(
    notes: [NoteletVersionNotes],
    version: NoteletPresentedVersion? = nil,
    onDismiss: @escaping () -> Void = {},
    configuration: NoteletConfiguration = .init(),
    userDefaults: UserDefaults = .standard
  ) -> some View {
    modifier(
      NoteletSheet(
        notes: notes,
        version: version,
        onDismiss: onDismiss,
        configuration: configuration,
        userDefaults: userDefaults
      )
    )
  }
}
