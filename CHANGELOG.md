# Changelog

All notable changes to Random Kit App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned

- Dark mode support
- Enhance Dice Feature
- Enhance Number Generator
- Enhance Coin Flip
- Enhance Color Mixer
- Enhance Wheel Spinner
- Multiple Dice (2-6 dice at once)
- Custom Dice (D4, D8, D12, D20)

---

## [2.1.0] - 2026-07-26

### Added

- **Persistent High Score Engine (`HighScoreService`)** - Best scores in Color Memory Game are now persisted locally using `shared_preferences` across app restarts.
- **In-App Contact Support Dialog** - Interactive feedback modal in Settings screen featuring category templates (General, Bug Report, Idea), email input, multiline message box, top `(X)` close button, and `nishanajihah.dev@gmail.com` dispatching.

### Changed

- **Color Memory Game UI & Sizing Overhaul**:
  - Applied Brand Orange (`#F4750A`) theme across start overlay, buttons, and progress bar.
  - Replaced central play arrow with interactive brain memory icon (`Icons.psychology_rounded`).
  - Matched `GameStatsHeader` and `StatusMessageBanner` font sizes to Tic Tac Toe cards.
  - Fixed color grid height (310px) with `Clip.none` padding to prevent layout shifting and clip-free highlight glow animations.
  - Level grid expansion fine-tuned with 1.0 square aspect ratio boxes.
  - Redesigned `GameOverDialog` with wider layout, persistent high score display, and symmetrical `EXIT GAME` & `PLAY AGAIN` control buttons.
- **Tic Tac Toe Visual & Font Refinements**:
  - Redesigned header into 3 score cards (`PLAYER X`, `DRAWS`, `PLAYER O / AI`).
  - Applied Brand Orange theme to board grid, status banner, mode toggle, and control buttons.
  - Standardized consistent 16px vertical gaps between all layout sections to eliminate screen scrolling.
- App version bumped to `2.1.0+8`.

---

## [2.0.0] - 2026-07-23

### Added

- **Tic Tac Toe Game (X vs O)** - Full-featured Tic Tac Toe mini-game with 2-player local pass & play and VS AI mode (with smart minimax decision making, win line animations, and score tracking).
- **Color Game (Visual Memory)** - Interactive color sequence memory game.
- **Settings Screen** - Comprehensive app settings and configuration options.
- **Modern Glassmorphism UI System** - Redesigned home screen and feature screens with glowing gradients, neumorphic cards, glass headers, and ad banner integration.

### Changed

- App version bumped to `2.0.0+7` (Major Version 2.0.0, Build 7).
- Updated Home Screen layout to display the modern Tic Tac Toe card.
- Cleaned up build queue lock configuration and updated `.gitignore` for Android build artifacts.

### Removed

- Removed legacy Haptic Memory Game implementation (`haptic_memory_game_screen.dart`, `haptic_memory_game_logic.dart`, `haptic_generator_logic.dart`, `HapticGameItem`).

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
