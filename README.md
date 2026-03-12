# Pigeon

Pigeon is a lightweight, type-safe networking library for Swift built on top of `URLSession` and modern `async/await` concurrency. It simplifies API interactions by providing a clean abstraction for request building, path management, and response decoding.

## Features

- **Async/Await Support**: Fully leverages Swift's modern concurrency model.
- **Type-Safe Requests**: Easily send `Encodable` bodies and receive `Decodable` responses.
- **Path Management**: Clean URL path construction using the `URLPath` type.
- **Built-in Authentication**: Simplified handling for Basic and Bearer token authorization.
- **Customizable**: Integrated support for custom `JSONEncoder` and `JSONDecoder` configurations.
- **Multi-Platform**: Supports iOS 15+ and macOS 12+.

## Installation

Add Pigeon as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ramble-logic/Pigeon.git", from: "1.0.0")
]
```

Or add it via Xcode's Swift Package Manager integration.

## Usage

### Basic Setup

Initialize a `Pigeon` with your API's host and a base path:

```swift
import Pigeon

let apiPigeon = Pigeon(host: "api.example.com", relativePath: ["v1"])
```

### Making a GET Request

Perform a simple request and receive a typed response:

```swift
let pokemon: Pokemon = try await apiPigeon.request(.get, path: ["pokemon", "charmander"])
print(pokemon.name)
```

### Making a POST Request with Body

Send a model as the request body:

```swift
let newUser = User(name: "Ash Ketchum", job: "Trainer")
let responseUser: User = try await apiPigeon.request(.post, path: "users", body: newUser)
```

### Authentication

Configure global authorization for your service:

```swift
apiPigeon.authorization = .bearer(token: "your_api_token")
// Or for Basic Auth:
// apiPigeon.authorization = .basic(username: "user", password: "pass")
```

### Custom Configuration

You can customize the underlying `URLSession`, `JSONEncoder`, or `JSONDecoder`:

```swift
apiPigeon.decoder.keyDecodingStrategy = .convertFromSnakeCase
apiPigeon.session = URLSession(configuration: .ephemeral)
```

## Core Components

- **`Pigeon`**: The primary class for configuring your API and performing requests.
- **`URLPath`**: A flexible type for representing URL paths, supporting array and string literals.
- **`HTTPAuthorization`**: An enum for common authorization headers (`.basic`, `.bearer`, `.other`).
- **`HTTPMethod`**: Standard HTTP verbs (`.get`, `.post`, `.put`, `.delete`, etc.).
- **`HTTPHeader`**: A simple struct for managing request headers.

## Platform Support

- **iOS**: 15.0+
- **macOS**: 12.0+
- **Swift**: 5.6+

## Dependencies

Pigeon is a lightweight library with no external dependencies beyond Apple's `Foundation` framework.
