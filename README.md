<p align="center">
  <img src="Assets/logo.png" alt="Notelet logo" width="84" height="84" />
</p>

<h3 align="center">Notelet</h3>

<p align="center">SwiftUI package for showing rich release notes in iOS apps</p>

<p align="center">
    <img src="https://img.shields.io/badge/iOS-17.0+-2980b9.svg" />
    <img src="https://img.shields.io/badge/iPadOS-17.0+-8e44ad.svg" />
</p>

<p align="center">
  <video src="https://github.com/user-attachments/assets/dd636105-82bb-4fd2-8d5a-ada9e9e4c38c" controls muted playsinline height="600px" width="auto"></video>
</p>

> [!TIP]
> Once you're done here, check my other project [AppView](https://appview.dev) to get an optimized website for your app. It will boost downloads coming from web search and AI suggestions.

## Installation (Swift Package Manager)

1. In Xcode, open your app project.
2. Go to **File → Add Package Dependencies...**.
3. Enter the repo URL https://github.com/mykolaharmash/notelet into the search.
4. Click on "Add package".
5. Add `Notelet` to your app target.


## Usage

Here is a full usage example with comments to get started quickly. Below are more detailed explanations of how the component works and all available APIs.

```swift
import SwiftUI
// Import Notelet
import Notelet

/**
* Release notes for different versions of the app.
* There are three supported note types: .list, .media(kind: .image) and .media(kind: .video).
*/
private let notes: [NoteletVersionNotes] = [
    .init(
        version: "1.2.0",
        items: [
            .list(
                title: "What's new",
                rows: [
                    .init(
                        symbolSystemName: "wand.and.stars",
                        title: "New editor tools",
                        description: "More formatting options with less taps."
                    ),
                    .init(
                        symbolSystemName: "lock.shield.fill",
                        title: "Privacy update",
                        description: "Sensitive data handling is now stricter."
                    )
                ]
            ),
            .media(
                kind: .image,
                url: URL(string: "https://example.com/notes-image.jpg")!,
                title: "Updated UI",
                description: "Refreshed visuals across key screens."
            ),
            .media(
                kind: .video,
                url: URL(string: "https://example.com/notes-video.mp4")!,
                title: "Quick walkthrough",
                description: "A short clip showing the new flow."
            )
        ]
    ),
    .init(
        version: "1.2.1",
        items: [
            .media(
                kind: .image,
                url: URL(string: "https://example.com/archive.jpg")!,
                title: "Journal Archive",
                description: "Archive entries without deleting them permanently"
            )
        ]
    )
]

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
        /**
        * Add the sheet to the view hierarchy.
        * It takes the full list of notes for all versions
        * and the version you'd like to present to the user.
        * There are more parameters, described below.
        */
        .noteletSheet(
            notes: notes,
            /**
            * `version: .current` takes the current version from the app's bundle,
            * and tries to show notes for it if they are present inside `notes`.
            * It will also automatically save this version as "viewed" when
            * the sheet is dismissed.
            */
            version: .current
        )
    }
}
```

## Release notes for the current version

The most common use case is to show release notes for the latest app update. Attach `noteletSheet()` to your view and use `version: .current`.

```swift
.noteletSheet(
    notes: [...],
    version: .current
)
```

Notelet will automatically get the current app version from the bundle and show release notes. When the user dismisses the sheet, it will mark the current version as seen, so the user doesn't see the same release notes again.

> [!IMPORTANT]
> Notelet reads the current app version from your app bundle, specifically the `CFBundleShortVersionString` property. It's the version you see in Xcode inside the "General" tab for a target. Make sure to use this app version when adding it to the `notes` list; it might be different from the version you have in App Store Connect.

When specifying version directly as `version: .current`, the release notes sheet will appear automatically when the view hierarchy renders. You can also trigger the sheet manually via a State property.

```swift
struct ContentView: View {
    @State private var presentedVersion: NoteletPresentedVersion? = nil

    var body: some View {
        VStack {
            Text("Hello, world!")

            Button("Show Release Notes") {
                presentedVersion = .current
            }
        }
        .noteletSheet(
            notes: notes,
            version: presentedVersion
        )
    }
}
```

## Manually show notes for a specific version

You may also want to show release notes for app versions other than the current one, for example, to give users access to a historical changelog in app settings.

```swift
 .noteletSheet(
    notes: notes,
    version: .v("1.2.1")
)
```

## Defining release notes

The list of release notes for each app version is an array of `NoteletVersionNotes` structs. Each struct specifies the `version` and `items`.

You can have as many notes inside `items` for each version as needed, they will be arranged in a paging view with navigation either using the "Next" button or by swiping.

The array can be a global constant or a static property on some top level view. I personally keep it in a global constant.

```swift
let RELEASE_NOTES: [NoteletVersionNotes] = [
    .init(
        version: "1.2.0",
        items: [ ... ] // <-- release notes go here
    )
]
```

> [!TIP]
> `NoteletVersionNotes` and all its nested types conform to `Codable`, so you can load notes remotely at runtime.

## Note types

The `items` property for each app version is an array of `NoteletVersionNoteItem` enum cases. There are three supported note types:

* `.list`
* `.media(kind: .image)`
* `.media(kind: .video)`

### List

Shows a title and a set of rows, where each row has an SF Symbol, a title, and a description.

This type of note is ideal for showing the user a quick summary of the update.

```swift
let RELEASE_NOTES: [NoteletVersionNotes] = [
    .init(
        version: "1.2.0",
        items: [
            .list(
                title: "What's new",
                rows: [
                    .init(
                        symbolSystemName: "sparkles",
                        title: "Polished details",
                        description: "Small UI upgrades throughout the app."
                    )
                ]
            )
        ]
    )
]
```

> [!TIP]
> All text properties are defined internally as `LocalizedStringResource` so they automatically end up in the string catalog ready for localization.

### Image

Loads and shows an image along with a title and description. Great for updates that need a bit more visual context.

The image will be wrapped in a square container. Parts of the image will be cropped to fill the container if it has an aspect ratio other than 1:1. It's best to use square images or at least have the main subject in the center so it's not affected by the cropping.

```swift
let RELEASE_NOTES: [NoteletVersionNotes] = [
    .init(
        version: "1.2.0",
        items: [
            .media(
                kind: .image,
                url: URL(string: "https://example.com/preview.jpg")!,
                title: "UI preview",
                description: "A quick look at the redesign."
            )
        ]
    )
]
```

### Video

Loads and plays a video along with a title and description. Great for cases when a feature needs mini-onboarding, or when you just want to highlight it for the user.

Same as with images, the video will be wrapped in a square container, so parts of it might be cropped if it has a non-square aspect ratio.

```swift
let RELEASE_NOTES: [NoteletVersionNotes] = [
    .init(
        version: "1.2.0",
        items: [
            .media(
                kind: .video,
                url: URL(string: "https://example.com/demo.mp4")!,
                title: "Feature demo",
                description: "See the flow in action."
            )
        ]
    )
]
```

## Sheet dismiss callback

`.noteletSheet()` has an optional `onDismiss` parameter similar to the standard `.sheet()`.

> [!TIP]
> `onDismiss` is a good place to ask users for a review right after you showed them the app updates.

```swift
@Environment(\.requestReview) private var requestReview

...

.noteletSheet(
    notes: notes,
    version: .current,
    onDismiss: {
        requestReview()
    }
)
```

## Additional configuration

`.noteletSheet()` accepts an optional `NoteletConfiguration` struct where you can customize button labels and accent color.

```swift
.noteletSheet(
    notes: notes,
    version: .current,
    configuration: .init(
        nextButtonLabel: "Continue",
        doneButtonLabel: "Got it",
        accentColor: .orange
    )
)
```

## Latest viewed version storage

When using `version: .current`, Notelet automatically marks the current version as seen by saving it to `UserDefaults`.

In some cases, you might also want to save it manually. For example, I don't want new users to see the release notes sheet right after onboarding, so when onboarding is done, I manually mark the current version as seen, and they only see release notes on the next update.

```swift
NoteletStorage.markCurrentVersionAsSeen()
```

For debugging purposes, you might also want to reset the storage value:

```swift
NoteletStorage.resetSeenVersion()
```
