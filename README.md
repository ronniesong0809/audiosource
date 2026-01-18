# AudioSourceApp

AudioSourceApp is a macOS SwiftUI prototype inspired by SoundSource. It focuses on the UI flows for splitting audio per source, picking devices, and previewing meters. The current build ships with mock data and wiring that you can replace with Core Audio or virtual driver integrations.

## Features
- Per-app routing layout with input and output pickers.
- Global system output + input controls.
- Capture loopback toggle and metering indicators.
- Output device inventory with default badges.

## Getting Started
1. Open the project in Xcode by selecting the `Package.swift` file.
2. Run the `AudioSourceApp` scheme on macOS 13 or newer.

## Next Steps
- Integrate Core Audio device discovery.
- Build a virtual audio driver to split per-app audio streams.
- Persist routing selections per app bundle identifier.
