# Hourly Chime

A lightweight, Apple Silicon-only menu bar app that plays the classic macOS “Glass” chime at the top of every hour. The app stays out of the Dock, shows its status in the menu bar, and lets you pause or trigger the chime on demand.

## Features

- Always-on menu bar extra with a bell icon that reflects whether the scheduler is active.
- Toggle to enable or pause the hourly timer.
- Clear “next chime” readout using your current locale.
- Manual “Ring Now” button for a quick sound test.
- “Glass” system sound playback (falls back to the default beep if unavailable).

## Requirements

- macOS 13 Ventura or newer (Apple Silicon only, per the requirement).
- Xcode 16 beta or the latest Swift 6.2+ toolchain.

## Building & Running

1. Open the folder in Xcode (`open Package.swift` or `xed .`), select the `chime` scheme, and choose a My Mac (Designed for Apple Silicon) destination.
2. Press **Run**. Xcode will build a `.app` bundle and launch it straight into the menu bar.
3. The app icon appears near the system clock. Use the menu to toggle the hourly chime, ring immediately, or quit.

> **Note:** Running `swift build` from the CLI may require the exact Xcode toolchain that matches your installed macOS SDK. If the two are out of sync (as on this machine), build via Xcode instead.

## Customizing the Sound

The app currently plays the built-in `Glass` sound. To change it, update `chimeSound` in `Sources/chime/HourlyChimeApp.swift` to another `NSSound.Name`, or load your own audio file with `NSSound(contentsOf:byReference:)`.

## How It Works

- `MenuBarExtra` (macOS 13+) hosts the UI in the menu bar.
- `HourlyChimeScheduler` keeps track of the next “top of the hour,” schedules a `Timer`, and plays the sound when the timer fires.
- Formatter logic keeps the UI reactive, so the toggle and next-fire time stay in sync with the scheduler.
