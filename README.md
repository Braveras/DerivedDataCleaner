# DerivedDataCleaner

Menu bar app for macOS. Click the trash icon → DerivedData deleted → system notification with MB freed.

## Install

Download `DerivedDataCleaner.zip` from [Releases](../../releases), unzip, drag to `/Applications`.

**First launch:** Right-click → Open (required once since the app is unsigned).  
Or run: `xattr -d com.apple.quarantine DerivedDataCleaner.app`

## Build from source

Requires Xcode 15+ and macOS 13+.

```bash
git clone https://github.com/YOUR_USERNAME/DerivedDataCleaner
open DerivedDataCleaner.xcodeproj
```

Press ⌘R to run. Change `PRODUCT_BUNDLE_IDENTIFIER` in build settings if needed.

## Release a new version

```bash
git tag v1.x.0
git push origin v1.x.0
```

GitHub Actions builds and publishes the release automatically.

---

## Ideas for future features

| Feature | Description |
|---|---|
| **Right-click menu** | Quit, Open DerivedData folder, Show current size |
| **SPM cache** | Clear `~/.swiftpm` and `.build` folders |
| **Simulator cache** | Clear `~/Library/Developer/CoreSimulator/Caches` |
| **Module cache** | Clear `~/Library/Developer/Xcode/ModuleCache.noindex` |
| **Size badge** | Show DerivedData size in menu bar tooltip on hover |
| **Multiple targets** | Checkboxes to select what to clean |
| **Auto-clean** | Option to clear on Xcode launch (via launchd / FSEvents) |
| **Login item** | Auto-start at login via `SMAppService` |
