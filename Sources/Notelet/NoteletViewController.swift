//
//  NoteletViewController.swift
//  Notelet
//

import SwiftUI
import UIKit

final class NoteletHostingController: UIHostingController<NoteletSheetContentView> {

    private let isCurrentVersionMode: Bool
    private let userDefaults: UserDefaults
    private let onDismiss: @MainActor () -> Void

    init(
        versionNotes: [NoteletVersionNoteItem],
        configuration: NoteletConfiguration,
        isCurrentVersionMode: Bool,
        userDefaults: UserDefaults,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.isCurrentVersionMode = isCurrentVersionMode
        self.userDefaults = userDefaults
        self.onDismiss = onDismiss
        super.init(rootView: NoteletSheetContentView(versionNotes: versionNotes, configuration: configuration))
        view.backgroundColor = .clear
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isBeingDismissed || isMovingFromParent else { return }

        if isCurrentVersionMode {
            NoteletStorage.markCurrentVersionAsSeen(userDefaults: userDefaults)
        }

        onDismiss()
    }
}

extension UIViewController {

    public func presentNoteletSheet(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion = .current,
        onDismiss: @escaping @MainActor () -> Void = { },
        configuration: NoteletConfiguration = .init(),
        userDefaults: UserDefaults = .standard
    ) {
        guard let presentation = NoteletPresenter.presentation(
            notes: notes,
            version: version,
            userDefaults: userDefaults
        ) else { return }

        let viewController = NoteletHostingController(
            versionNotes: presentation.versionNotes,
            configuration: configuration,
            isCurrentVersionMode: presentation.isCurrentVersionMode,
            userDefaults: userDefaults,
            onDismiss: onDismiss
        )

        if let sheet = viewController.sheetPresentationController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                sheet.detents = [.large()]
            } else {
                let customDetent = UISheetPresentationController.Detent.custom(
                    identifier: .init("notelet.fraction")
                ) { $0.maximumDetentValue * CGFloat(configuration.sheetFractionHeight) }

                sheet.detents = [customDetent]
            }

            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }

        present(viewController, animated: true)
    }
}
