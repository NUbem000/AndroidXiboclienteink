# Architecture Documentation

## Overview

AndroidXiboClientEink follows **Clean Architecture** principles with **MVVM** pattern for the presentation layer.

## Layers

### 1. Presentation Layer (UI)
- **Activities/Fragments**: UI controllers
- **ViewModels**: UI state management
- **Views**: Custom views for e-ink optimization

### 2. Domain Layer
- **Use Cases**: Business logic encapsulation
- **Domain Models**: Core business entities
- **Repository Interfaces**: Data access contracts

### 3. Data Layer
- **Repository Implementations**: Data source coordination
- **API Service**: Xibo CMS REST API client
- **Database**: Room database for local cache
- **Models**: Data transfer objects (DTOs)

### 4. E-ink Layer (Native)
- **EinkDisplayManager**: JNI bridge to native code
- **Native Controller**: C++ implementation for display control

## Data Flow

```
UI (Activity)
    ↓ observes
ViewModel
    ↓ calls
Use Case
    ↓ accesses
Repository
    ↓ fetches from
[API Service | Local Database]
```

## Dependencies

- **Hilt**: Dependency injection
- **Retrofit**: HTTP client
- **Room**: Local database
- **Coroutines**: Asynchronous operations
- **Timber**: Logging

## Module Structure

```
app/
├── ui/              # Presentation layer
├── data/            # Data layer
├── domain/          # Business logic
├── eink/            # E-ink specific code
└── utils/           # Shared utilities
```

## Key Components

### EinkDisplayManager
Central component for e-ink display control. Interfaces with native code via JNI.

### MainActivity
Entry point of the application. Handles fullscreen mode and basic e-ink testing.

### Future Components
- XiboApiClient: Xibo CMS integration
- ScheduleManager: Content scheduling
- ContentRenderer: Media rendering
- CacheManager: Content caching

## Testing Strategy

- **Unit Tests**: Use Cases, ViewModels
- **Integration Tests**: Repository, API
- **UI Tests**: Activities, key user flows
- **Native Tests**: E-ink controller logic
