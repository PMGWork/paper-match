# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

- **Build project**: Open `paperMatch.xcodeproj` in Xcode and use Cmd+B to build
- **Run app**: Use Xcode's Run button (Cmd+R) or run on simulator
- **iOS deployment target**: iOS 26.0 (Swift 5.0, Xcode 26.0)

## Architecture Overview

This is a SwiftUI iOS app called "paperMatch" that helps users discover and manage academic papers from ArXiv. The app follows MVVM architecture with reactive programming using Combine.

### Key Components

**Models (`Models/`)**:
- `Paper`: Core data model representing academic papers with metadata, translation support, and like/read status
- `Genre`: Represents search categories with ArXiv query strings, managed through GenreManager

**Services (`Services/`)**:
- `ArXivService`: Handles ArXiv API integration with XML parsing, includes fallback to sample data when API fails
- `TranslationService`: Provides translation capabilities using Apple's Translation framework (iOS 17.4+) with comprehensive mock translation fallback

**ViewModels (`ViewModels/`)**:
- `PaperStore`: Main data store managing paper state, search operations, and persistence via UserDefaults

**Views (`Views/`)**:
- `MainTabView`: Root tab interface with Home and Library tabs
- View hierarchy includes paper cards, search functionality, saved papers, and genre management

### Data Flow

1. App launches → `PaperStore` initializes → loads saved papers from UserDefaults
2. `ArXivService` fetches papers via XML API → falls back to sample data on failure
3. Papers can be liked/saved → persisted to UserDefaults
4. Genre system allows custom search queries for different paper categories
5. Translation service converts English abstracts/titles to Japanese

### Key Features

- ArXiv paper discovery with category-based filtering
- Paper saving/liking with local persistence
- Japanese translation support with Apple Translation framework
- Genre management for customized paper discovery
- Offline functionality with sample data fallback

### Development Notes

- Uses `@StateObject` and `@Published` for reactive UI updates
- Combine framework for async operations and data binding
- UserDefaults for simple local data persistence
- Comprehensive error handling with fallback mechanisms
- Mock translation patterns for development/testing without API access