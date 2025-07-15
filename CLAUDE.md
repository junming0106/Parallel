# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Parallel** (心連心) is a couple-exclusive emotional connection app designed to create a warm digital haven for couples. The app provides an extremely private, fun, and seamlessly integrated daily tool that not only addresses communication and collaboration needs between couples but also creates unique experiences to deepen emotional connections through technology.

### Target Users
- Primary: Ages 18-35, tech-savvy couples in stable relationships or long-distance relationships
- Value proposition: More private and exclusive than general social platforms (Line, Messenger)
- Focus: Couples seeking ritual sense in life and shared memories

### Core Product Pillars
The app revolves around four main themes: **Communication**, **Companionship**, **Memories**, and **Planning**.

## Architecture

### Core Components
- **Main App** (`Parallel/`): SwiftUI-based iOS app with SwiftData for local persistence
- **Widgets Extension** (`Widgets/`): WidgetKit widgets for home screen integration
- **Tests** (`ParallelTests/`, `ParallelUITests/`): Unit and UI test suites

### Key Files
- `ParallelApp.swift`: Main app entry point with SwiftData model container setup
- `ContentView.swift`: Primary view with navigation and item management
- `Item.swift`: SwiftData model for basic data entities
- `Widgets.swift`: Widget implementation using AppIntentTimelineProvider
- `WidgetsBundle.swift`: Widget bundle configuration

### Tech Stack
- **Platform**: iOS 17.0+
- **UI Framework**: SwiftUI for modern, responsive interface with seamless WidgetKit integration
- **Data Layer**: SwiftData for local persistence and tight SwiftUI integration
- **Widgets**: WidgetKit for home screen widgets
- **Location Services**: Core Location for real-time location sharing and geofencing
- **Backend Services** (Planned - Firebase):
  - Authentication: Firebase Auth (Apple ID, Email)
  - Database: Firestore for user data, diaries, calendar events
  - Real-time Communication: Firebase Realtime Database/Cloud Messaging
  - Storage: Cloud Storage for images and videos

### Core Features to Implement

#### 1. Private Messaging (Chat)
- End-to-end encryption for all content
- Multimedia support (images, videos, voice messages)
- Exclusive emoji store with cute/romantic themes
- "Miss You" button with full-screen heart animation
- Message status indicators (sent/delivered/read)
- iCloud sync for chat history

#### 2. Real-time Location & Distance Tracking
- Selective location sharing (permanent/24h/1h/off)
- Destination distance tracking with real-time updates
- Battery level display to reduce anxiety
- Geofencing for home/work arrival/departure notifications
- Privacy-focused with encrypted location data

#### 3. Shared Diary Exchange
- Collaborative digital diary with exchange mode
- Rich editing (text formatting, photos, weather)
- Customizable diary covers and paper styles
- Memory timeline for completed diaries
- Surprise element through locked exchange system

#### 4. Shared Calendar
- Bidirectional sync for events
- Event types: anniversaries, dates, travel, todos
- Smart reminders with customizable timing
- Anniversary countdown display
- Automatic yearly recurring events

#### 5. Home Screen Widgets
- Multiple sizes (small, medium, large)
- Anniversary countdown widget
- Relationship days counter
- Quick "Miss You" button
- Partner status updates (with permission)

## Common Development Commands

### Building and Testing
```bash
# Build the project
xcodebuild -project Parallel.xcodeproj -scheme Parallel -configuration Debug build

# Run unit tests
xcodebuild -project Parallel.xcodeproj -scheme Parallel -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run UI tests
xcodebuild -project Parallel.xcodeproj -scheme Parallel -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:ParallelUITests test
```

### Xcode Development
- Open `Parallel.xcodeproj` in Xcode
- Main scheme: `Parallel`
- Widget scheme: `WidgetsExtension`
- Supports both iOS device and simulator targets

## Development Notes

### SwiftData Usage
- Model container is configured in `ParallelApp.swift`
- Uses `@Model` macro for data entities (see `Item.swift`)
- Environment model context available throughout the app

### Widget Development
- Widget extension located in `Widgets/` directory
- Uses `AppIntentTimelineProvider` for configuration
- Supports multiple widget types: standard widgets, controls, and live activities

### Project Structure
```
Parallel/
├── Parallel.xcodeproj/          # Xcode project file
├── Parallel/                    # Main app source
│   ├── Assets.xcassets/         # App assets
│   ├── ParallelApp.swift        # App entry point
│   ├── ContentView.swift        # Main view
│   └── Item.swift               # Data model
├── Widgets/                     # Widget extension
│   ├── Widgets.swift            # Widget implementation
│   ├── WidgetsBundle.swift      # Widget bundle
│   └── Assets.xcassets/         # Widget assets
├── ParallelTests/               # Unit tests
├── ParallelUITests/             # UI tests
└── Parallel_PRD.md              # Product requirements document
```

## Development Guidelines

### Security & Privacy Requirements
- **CRITICAL**: All communication must use end-to-end encryption
- Location data must be encrypted during transmission
- Follow Apple's privacy guidelines strictly
- Clear privacy policy and user permission management
- No logging of sensitive information

### Performance Requirements
- App launch within 2 seconds
- Smooth scrolling and map operations
- Battery-optimized location tracking
- Efficient background location updates

### UI/UX Guidelines
- Follow Apple Human Interface Guidelines
- Maintain consistency with iOS design patterns
- Focus on intuitive, couple-friendly interactions
- Warm, romantic visual design language

### Business Model
- **Freemium model**: Core features free, premium subscription for advanced features
- **Free version**: Basic functionality with storage/style limitations
- **Parallel Plus subscription**: Unlimited storage, premium themes, advanced widgets, ad-free

## Implementation Roadmap

### V1.0 (MVP)
- [ ] User authentication and couple pairing
- [ ] Basic private messaging with encryption
- [ ] Real-time location sharing
- [ ] Simple shared diary
- [ ] Basic calendar integration
- [ ] Essential widgets

### V1.1 (Short-term)
- [ ] iPad support
- [ ] Holiday-themed emoji packs
- [ ] Battery optimization improvements
- [ ] Enhanced widget customization

### V2.0 (Long-term)
- [ ] Shared photo album with automatic categorization
- [ ] Couple bucket list with progress tracking
- [ ] Daily couple challenges and questions
- [ ] Apple Watch companion app

## Development Best Practices

- Prioritize data security and user privacy in all implementations
- Use SwiftUI's latest features for optimal performance
- Implement proper error handling for network operations
- Follow MVVM architecture patterns with SwiftUI
- Write comprehensive unit tests for core functionality
- Test thoroughly on various iOS devices and versions

When implementing new features, always consider the couple-centric use case and emotional connection aspect of the app.