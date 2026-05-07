import Foundation

public func noteletMarkCurrentVersionAsSeen() {
    UserDefaults.standard.set(
        Helpers.getCurrentAppVersion(),
        forKey: NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY
    )
}
