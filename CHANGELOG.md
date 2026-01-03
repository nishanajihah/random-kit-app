# Changelog

All notable changes to Random Kit App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned

- Settings
- Dark mode support
- Enhance Dice Feature
- Enhance Number Generator
- Enhance Coin Flip
- Enhance Color Mixer
- Enhance Wheel Spineer
- Enhance Haptic Generator
- Multiple Dice (2-6 dice at once)
- Custom Dice (D4, D8, D12, D20)

### In Progress

- Settings and Enhance Home Screen

### Fixed Unreleased

- Nothing currently

---

## [1.5.0-alpha.1] - 2026-01-04

### Added

- **Random Haptic Feedback Generator** - Feel the randomness!
  - 9 unique vibration patterns: Heartbeat, Pulse, Taps, Rumble, Buzz, The Zap, Machine Gun, Slow Pulse, and Morse SOS.
  - Randomized pattern selection logic for variety.
  - Comprehensive Unit Tests for the Haptic Logic and pattern integrity.
- Category metadata: Defined app as "Entertainment" in Android Manifest.

### Changed

- Updated versioning logic to move out of the 1.4.x alpha branch.
- Optimized internal randomizer efficiency for pattern selection.

---

[1.4.0-alpha.1] - 2025-12-17

### Added

Wheel Spinner feature - Decision-making wheel with customizable options

- Animated spinning wheel with smooth animations
- Add/edit/delete options with intuitive dialog interface
- Minimum 2 options, maximum 10 options
- Color-coded wheel segments for better visibility
- Real-time winner display after spin completes
- Numbered list view for easy option management
- Warning dialog for insufficient options

### Changed

- Home screen redesigned with vertical scrolling layout
- Feature buttons now use zigzag pattern (alternating left/right icon placement)
- Improved UI consistency across all feature screens

### Fixed

- Bottom overflow issue on all screens with edge-to-edge display
- Ad banner positioning with SafeArea implementation
- Stream listener errors in FortuneWheel widget
  
---  

## [1.3.0-alpha.1] - 2025-12-7

### Added

- Color Mixer feature

### Changed

- Change ad banner design and bottom layout

---

## [1.2.0-alpha.1] - 2025-11-27

### Added

- Coin Flipper feature (Heads/Tails)

### Changed

- App name updated to "Random Kit+ Idle"

---

## [1.1.0-alpha.1] - 2025-11-23

### Added

- Number Generator feature with customizable min/max range
- Hub-style home screen with feature cards navigation
- Dynamic AppBar with "Random Kit" branding and feature-specific titles
- Separate ad unit ID support for each feature screen

### Changed

- Refactored ad banner code into reusable widget
- Navigation flow: Home → Feature screens (push navigation)
- Improved screen layouts with centered content

### Fixed

- Content centering on Dice Roller and Number Generator screens

---

## [1.0.0] - 2025-10-29

### Added

- Dice roller feature with D6 support
- Clean, modern UI with orange theme
- Fast and responsive
- Offline-friendly with graceful ad handling
- Ad-supported (free to use)
- Custom app icon
- App renamed to "Random Kit"
- Package name: com.nishanajihah.randomkit

### Changed

- Initial internal release

### Fixed

- N/A (first release)
