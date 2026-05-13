import Foundation

public final class NoteletStorage {
    /// Mark the current bundle version as seen.
    ///
    /// - Parameter userDefaults: Storage to write to. Defaults to `.standard`.
    ///   Pass `UserDefaults(suiteName: "group.com.example.myapp")` to share the
    ///   "seen" state with an App Group target (widget, intent, share extension).
    public static func markCurrentVersionAsSeen(userDefaults: UserDefaults = .standard) {
        userDefaults.set(
            Helpers.getCurrentAppVersion(),
            forKey: NoteletStorageKey.latestSeenAppVersion
        )
    }

    /// Clear the persisted "latest seen version" so the next `.current`
    /// presentation triggers regardless of bundle version.
    ///
    /// - Parameter userDefaults: Storage to clear. Defaults to `.standard`.
    ///   Pass an App Group `UserDefaults` here if you used one in
    ///   `markCurrentVersionAsSeen(userDefaults:)`.
    public static func resetSeenVersion(userDefaults: UserDefaults = .standard) {
        userDefaults.removeObject(forKey: NoteletStorageKey.latestSeenAppVersion)
    }

    /// Read the persisted "latest seen version" string, or `nil` if it has
    /// never been set.
    ///
    /// - Parameter userDefaults: Storage to read from. Defaults to `.standard`.
    /// - Returns: The bundle version string the user last saw, or `nil`.
    public static func getLatestSeenAppVersion(userDefaults: UserDefaults = .standard) -> String? {
        userDefaults.string(forKey: NoteletStorageKey.latestSeenAppVersion)
    }
}
