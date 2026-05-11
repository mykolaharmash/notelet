//
//  NoteletViewController.swift
//  Notelet
//

import SwiftUI
import UIKit

// MARK: - Hosting controller

final class NoteletHostingController: UIHostingController<NoteletSheetContentView> {
    
    private let isCurrentVersionMode: Bool
    private let onDismiss: @MainActor () -> Void

    init(
        versionNotes: [NoteletVersionNoteItem],
        configuration: NoteletConfiguration,
        isCurrentVersionMode: Bool,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.isCurrentVersionMode = isCurrentVersionMode
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
        if isCurrentVersionMode { NoteletStorage.markCurrentVersionAsSeen() }
        onDismiss()
    }
}

// MARK: - UIViewController extension

extension UIViewController {

    public func presentNoteletSheet(
        notes: [NoteletVersionNotes],
        version: NoteletPresentedVersion = .current,
        onDismiss: @escaping @MainActor () -> Void = { },
        configuration: NoteletConfiguration = .init(),
        sheetFractionHeight: CGFloat = 0.85
    ) {
        guard let resolved = NoteletPresenter.resolve(notes: notes, version: version) else {
            return
        }
        let vc = NoteletHostingController(
            versionNotes: resolved.versionNotes,
            configuration: configuration,
            isCurrentVersionMode: resolved.isCurrentVersionMode,
            onDismiss: onDismiss
        )
        if let sheet = vc.sheetPresentationController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                sheet.detents = [.large()]
            } else {
                let fraction85 = UISheetPresentationController.Detent.custom(
                    identifier: .init("notelet.85percent")
                ) { $0.maximumDetentValue * sheetFractionHeight }
                sheet.detents = [fraction85]
            }
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }
        
        present(vc, animated: true)
    }
    
}
