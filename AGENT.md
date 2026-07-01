# AGENT.md

Maintainer/agent guide for **I Wanna RWX** — a minimalist iOS app for "to-read"/"to-watch" lists and recurring reminders (subscriptions & licenses). This document describes the architecture, conventions, and how to build/test. For the product description, see [README.md](README.md).

## Tech stack

- **UI:** SwiftUI (iOS 26 deployment target, Swift 5 language mode)
- **Persistence:** SwiftData with CloudKit sync (`cloudKitDatabase: .automatic`)
- **State:** `@Observable` singletons for app-level services; `@State` + `@Query` in views
- **Platforms:** iOS + Mac Catalyst
- **External data:** OpenLibrary (books, self-written client), TMDb (movies, via the [TMDb](https://github.com/adamayoung/TMDb) Swift package; requires a user-provided API key)
- **Tests:** XCTest with in-memory SwiftData containers

## Architecture

Feature-based, with each feature split into `Data` / `Domain` / `Presentation` layers. Cross-feature code lives in `Shared/`, app infrastructure in `Core/`.

```
book_film_inbox/
├── App/                      # @main entry (book_film_inboxApp), AppDelegate
├── Core/
│   ├── Persistence/          # PersistenceController — ModelContainer + schema registration
│   ├── Services/             # NavigationManager, SettingsService, NotificationService, LogService (Log)
│   └── Utilities/            # SettingsSourceStore, KeychainHelper, FilterStore, ...
├── Shared/
│   ├── Domain/               # CommonMediaItem, CommonFilterState, MediaFilterState, TriState, MediaStatus
│   ├── Data/                 # MediaPersistenceService (base), SearchService
│   └── Presentation/         # ContentView (tabs), Components/, Widgets/, ItemCards/
└── Features/
    └── Books/  Movies/  Reminders/  Settings/
        ├── Data/             # <Feature>PersistenceService, External<Feature>Item, API clients, Draft service
        ├── Domain/           # SwiftData schema (versioned), typealias item, migration plan, enums
        └── Presentation/     # <Feature>View + feature-specific components
```

Xcode groups are **filesystem-synchronized** (`PBXFileSystemSynchronizedRootGroup`): new files placed in the tree are automatically part of the target — no `.pbxproj` editing needed.

## Data model

Three SwiftData entities, registered in `Core/Persistence/PersistenceController.swift`:

- `BookItem` (schema `BookSchemaV102`)
- `MovieItem` (schema `MovieSchemaV100`)
- `ReminderItem` (schema `ReminderSchemaV100`)

Books and Movies conform to the `CommonMediaItem` protocol (`Shared/Domain/CommonMediaItem.swift`), which is what most shared UI and services are generic over. Each has a versioned schema + a `*MigrationPlan`.

## Key patterns to reuse

- **Generic media list:** `Shared/Presentation/Widgets/MediaListContent.swift` renders any `CommonMediaItem` list. Books/Movies views instantiate it with a `Predicate` built from their filter state. It owns the `@Query`.
- **Persistence services:** `MediaPersistenceService` (base) + per-feature subclasses; injected via `@Environment`.
- **Filtering:**
  - `TriState` (`.all` / `.include` / `.exclude`) drives favorite/seen/draft checkboxes.
  - `MediaFilterState<TF>` (books/movies) and `ReminderFilterState` conform to `CommonFilterState` and are `Codable`.
  - `CommonFilterSheet` + a per-feature "characteristics section" build the filter UI. The **Reset** button restores `appDefault` (single source of truth on each filter-state type — e.g. media defaults to hiding "seen" items).
  - `FilterToolbarButton` shows the active-filter count badge.
- **Filter persistence:** `Core/Utilities/FilterStore.swift` saves/loads each list's `Codable` filter to `UserDefaults` (keys under `FilterStore.Key`). Views seed `@State` from it in `init()` and save via `.onChange`. This mirrors how `NavigationManager` persists the selected tab. Device-local (not CloudKit-synced), like the selected tab.
- **List item counts:** `Shared/Presentation/Components/ListCountPreference.swift`. List content views report `ListCounts(total:shown:)` via `.reportListCounts(...)` (a `PreferenceKey`); each screen observes it with `.onPreferenceChange(ListCountsKey.self)` and renders `ListCountLabel` in the toolbar. `total` comes from an unfiltered `@Query`; `shown` from the filtered/searched result.
- **Navigation:** `NavigationManager` (`@Observable` singleton) owns the selected tab (persisted to `UserDefaults`) and per-tab `NavigationPath`s.
- **Logging:** use `Log.debug(_:context:)` (LogService), not `print`.

## Localization

- All user-facing strings are `LocalizedStringKey`s using dotted keys (e.g. `.label.common.list_empty`).
- Strings live in the String Catalog `book_film_inbox/Resources/Localizable.xcstrings`. Languages: **en** (source), **ru**, **uk** — add all three when introducing a key.
- Interpolated keys embed the placeholder in the key itself, e.g. `Text(".label.common.list.count \(total)")` maps to the catalog key `".label.common.list.count %lld"`. Use plural `variations` for count-dependent strings (see `.label.movies.tv_series.seasons %lld` as a template).
- No runtime language switch — device locale only.

## Adding a new media type (checklist)

1. `Domain/`: versioned `*SchemaVxxx` (SwiftData `@Model`), a `typealias <Name>Item`, and a `*MigrationPlan`. Conform to `CommonMediaItem` if it's a media list.
2. `Data/`: a `*PersistenceService` (subclass the base), an `External<Name>Item` for search results, an API client, and a Draft service if applicable.
3. `Presentation/`: a `<Name>View` using `MediaListContent`, a filter type enum conforming to `FilterTypeOption`, and `makePredicate`.
4. Register the new `@Model` type in `PersistenceController`'s `Schema`.
5. Add a `Tab` case + wiring in `ContentView` / `NavigationManager` if it's a new tab.
6. If it has a persisted filter, add a `FilterStore.Key` and seed/save in the view.
7. Add localized strings (en/ru/uk).

## Conventions

- File header block: `// <Name>.swift / book_film_inbox / Created by Slava Davydov on <date>`.
- Use `// MARK: -` to section larger files.
- Prefer reusing the generic shared widgets/components over per-feature reimplementations.
- Accessibility: provide `accessibilityLabel`/`accessibilityHint` for toolbar buttons and tappable rows (see existing views for the pattern).

## Build & test

Requires **Xcode** (Command Line Tools alone can't build a SwiftUI/SwiftData app target).

- List schemes: `xcodebuild -list`
- Build: `xcodebuild -project book_film_inbox.xcodeproj -scheme book_film_inbox -destination 'platform=iOS Simulator,name=iPhone 16' build`
- Test: `xcodebuild -project book_film_inbox.xcodeproj -scheme book_film_inbox -destination 'platform=iOS Simulator,name=iPhone 16' test`

Unit tests live in `IWannaRWXTests/Unit/`. Use `SwiftDataTestHelper` to spin up in-memory `ModelContainer`s (`isStoredInMemoryOnly: true`) and mark SwiftData/SwiftUI test cases `@MainActor`.
