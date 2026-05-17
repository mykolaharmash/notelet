//
//  Constants.swift
//  Notelet
//
//  Created by Mykola Harmash on 05.05.26.
//

/// Namespaced keys used by `NoteletStorage` when reading from or writing to a
/// `UserDefaults` instance. Exposed publicly so host apps that share state with
/// an extension target (widget, intent, share extension) can read or clear the
/// same keys from the App Group `UserDefaults`.
public enum NoteletStorageKey {
    /// The persisted app version string that was last seen by the user when a
    /// `noteletSheet` was dismissed in `.current` mode.
    public static let latestSeenAppVersion = "Notelet.LatestSeenAppVersion"
}

@available(*, deprecated, renamed: "NoteletStorageKey.latestSeenAppVersion", message: "Use NoteletStorageKey.latestSeenAppVersion instead.")
public let NOTELET_APP_STORAGE_LATEST_SEEN_APP_VERSION_KEY = NoteletStorageKey.latestSeenAppVersion
