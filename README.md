# WeatherApp

A weather lookup app for the iOS coding challenge. Search any US city or
use your current location; the app shows current conditions with a
cached weather icon and a detail screen.

## Running it

1. Open `WeatherApp.xcodeproj` in Xcode 26+
2. Build and run — an OpenWeather API key is included in
   `Application/Configuration/AppConfiguration.swift` for review
   convenience. In production this would live in an `.xcconfig`
   excluded from source control, or be fetched from a backend.
3. Run tests with ⌘U

## Architecture

MVVM-C with a composition root:

- **Coordinators** own navigation. `AppCoordinator` boots the app;
  `WeatherCoordinator` owns the feature flow. View controllers emit
  closure events and know nothing about other screens.
- **Containers** (`AppContainer` → `WeatherContainer`) build the
  dependency graph. Everything behind the ViewModel is a protocol,
  injected through initializers.
- **Layers**: ViewControllers/Views → ViewModel → Repository →
  DataSource, with DTOs decoded at the edge and mapped to a plain
  `Weather` domain model.
- **Both UI frameworks**: the search screen is programmatic UIKit;
  the detail screen is SwiftUI in a `UIHostingController`. Both adapt
  to orientation and size class changes.
- **`ImageLoader`** is an actor providing an in-memory icon cache with
  in-flight task de-duplication — concurrent requests for the same
  icon share one download, and both screens share one cache.

## Launch policy

On launch the app tries current location first. If permission is
denied or the fix fails, it falls back to the last searched city;
if nothing is saved, it prompts for a city search. The location
button reflects permission state — when denied, it routes to
Settings, and the app picks up location weather on relaunch.

## Tests

Unit tests cover the ViewModel and Model layers:

- `WeatherSearchViewModel`: input validation, search success and
  failure states, the persist-only-on-user-search rule, and the full
  location fallback chain (denied → saved city → prompt)
- `WeatherDetailViewModel`: display formatting
- `WeatherResponseDTO`: decoding against a real API response fixture

Location and storage are injected protocols, so tests drive the
permission flow directly — no simulator permission resets needed.

## A note on one workaround

`WeatherSearchViewModel` carries an explicit `nonisolated deinit {}`
to work around a known Swift toolchain bug
([swiftlang/swift#87316](https://github.com/swiftlang/swift/issues/87316)):
under `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, the synthesized
isolated deinit over-releases when an object is deallocated off the
main thread — which XCTest's teardown does. The app was unaffected;
only the test runner exercised the broken path.

## With more time

- Cancel in-flight search tasks when a new search starts (documented
  inline in `WeatherSearchViewModel`)
- UI tests for the search and navigation flows
- VoiceOver labels and Dynamic Type audit
- Localized strings catalog
- Disk-backed image cache tier