# thoughtcomplete – Claude instructions

## What this is
A minimal macOS freewrite app. Think Freewrite / iA Writer vibes — clean, distraction-free, no popups, no dropdowns. Everything is a clickable label that cycles through options.

---

## Fetching documentation
Always use `r.jina.ai/` as a prefix to fetch Apple or any other documentation URLs.

```
https://r.jina.ai/https://developer.apple.com/documentation/...
```

Never guess API signatures. If unsure, fetch the docs first.

---

## Platform
- **macOS 26.2**, Xcode 26
- **Swift 6**, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- Deployment target: `MACOSX_DEPLOYMENT_TARGET = 26.2`
- `xcodebuild` requires full Xcode: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

---

## Swift / SwiftUI patterns — macOS 26 / Swift 6

Use the **new** observation system. Never use the old one.

| Old (don't use)         | New (use this)                     |
|-------------------------|------------------------------------|
| `ObservableObject`      | `@Observable`                      |
| `@Published`            | plain `var` inside `@Observable`   |
| `@StateObject`          | `@State`                           |
| `@EnvironmentObject`    | `@Environment(Type.self)`          |
| `.environmentObject(x)` | `.environment(x)`                  |

### Liquid Glass
Use real Apple APIs — no custom `ultraThinMaterial` layering or manual borders.

- Floating overlays: `.glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))`
- Sidebar: `NavigationSplitView` — macOS applies Liquid Glass automatically
- Multiple nearby glass elements: wrap in `GlassEffectContainer`
- Fetch current API: `https://r.jina.ai/https://developer.apple.com/documentation/SwiftUI/GlassEffectContainer`

---

## Project structure

```
thoughtcomplete/
├── thoughtcompleteApp.swift      # @main, WindowGroup, .commands
├── AppState.swift                # @Observable coordinator (fontSizeIndex, store ref)
├── ContentView.swift             # NavigationSplitView root, all view state + actions
├── Models/
│   └── Thought.swift             # Identifiable, Codable, Hashable — Foundation only
├── Store/
│   └── ThoughtsStore.swift       # @Observable, UserDefaults persistence
├── Utilities/
│   └── WritingFont.swift         # WritingFont enum, fontSizes[], timerOptions[]
└── Views/
    ├── Editor/
    │   ├── EditorView.swift       # TextEditor + placeholder
    │   └── BottomBar.swift        # bottom bar, actions as closures
    ├── Sidebar/
    │   ├── SidebarView.swift      # List + ContentUnavailableView
    │   ├── ThoughtRow.swift       # single row
    │   └── ThoughtDetailOverlay.swift  # floating glass card
    └── Components/
        └── BarButton.swift        # plain monospaced hoverable button
```

`PBXFileSystemSynchronizedRootGroup` is used — Xcode auto-discovers files, no `pbxproj` edits needed when adding/moving files.

---

## Architecture decisions

- **No CoreData, no external dependencies** — `UserDefaults` + `JSONEncoder` is enough
- **`ThoughtsStore`** owns all persistence, separate from `AppState`
- **`Thought`** model imports only `Foundation`, not SwiftUI
- **`BottomBar`** receives all data + closures — no `@Environment` access, easier to reason about
- **`ContentView`** is the single source of truth for view state; all actions are `private` methods
- **Sidebar** toggled via `NavigationSplitViewVisibility` (`.detailOnly` / `.all`), not a custom bool
- **`ThoughtDetailOverlay`** floats over the editor as a `ZStack` overlay, not a sheet or popover

---

## UI conventions
- No dropdowns, no popups, no sheets
- All controls are plain text labels (`BarButton`) that cycle through options on click
- Bottom bar: `font name · font size · [spacer] · Save · Thoughts/Hide · timer · Start/Stop/Reset`
- Keyboard shortcuts: `Cmd+S` save, `Cmd+B` sidebar toggle, `Cmd++/-` font size
- Placeholder text: "Start writing..."
- Empty sidebar: `ContentUnavailableView`
- Saving a thought clears the editor and opens the sidebar

---

## Design ethos
Minimal and demure. Let macOS do the heavy lifting on glass, materials, and animations. Don't fight the system — use `NavigationSplitView`, `List(.sidebar)`, `ContentUnavailableView`, `.glassEffect()`. Avoid custom styling where a system component already exists.
