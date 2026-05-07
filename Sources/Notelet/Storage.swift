import Foundation

public final class NoteletStorage {
    public static func markCurrentVersionAsSeen() {
        UserDefaults.standard.set(
            Helpers.getCurrentAppVersion(),
            forKey: NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY
        )
    }

    public static func resetSeenVersion() {
        UserDefaults.standard.removeObject(forKey: NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY)
    }
}
