# Design Document: Pigeon

Pigeon is a lightweight, type-safe networking library for Swift, designed to simplify the interaction with RESTful APIs. It provides a clean abstraction over `URLSession`, leveraging modern Swift features like `async/await`, `Codable`, and strong typing for HTTP components.

## 1. High-Level Architecture

Pigeon follows a **Pigeon-Oriented Architecture** for networking. The core component is the `Pigeon` class, which acts as a central hub for configuring and executing network requests. It abstracts away the boilerplate of URL construction, header management, and data encoding/decoding.

### Technical Stack
- **Language:** Swift 5.5+
- **Frameworks:** Foundation, FoundationNetworking (for cross-platform compatibility)
- **Dependency Management:** Swift Package Manager (SPM)
- **Concurrency:** Swift Structured Concurrency (`async/await`)

---

## 2. Core Design Philosophies & Patterns

- **Type Safety:** HTTP methods, schemes, content types, and paths are represented by strongly-typed enums and structs to prevent runtime errors.
- **Composition over Inheritance:** Pigeons are designed to be configured and extended, allowing for easy dependency injection and modularity.
- **Convention over Configuration:** Sensible defaults (like JSON encoding/decoding) are provided, while still allowing full customization of `URLSessionConfiguration`, `JSONEncoder`, and `JSONDecoder`.
- **Cross-Platform:** Support for both Apple platforms (via `Foundation`) and Linux (via `FoundationNetworking`).

---

## 3. Key Components

### 3.1. `Pigeon`
The primary interface for executing requests. It maintains state such as:
- `host` and `port`
- `scheme` (HTTP/HTTPS)
- `relativePath` (base path for all requests)
- `authorization` and `contentType` defaults
- `URLSession`, `JSONEncoder`, and `JSONDecoder` instances

### 3.2. `URLPath`
A value type that implements `ExpressibleByArrayLiteral` and `ExpressibleByStringLiteral`. It allows for safe and expressive URL path construction using the `+` operator and array-like syntax.

### 3.3. HTTP Value Types
- **`HTTPMethod`**: Enum for GET, POST, PUT, DELETE, etc.
- **`HTTPScheme`**: Enum for `http` and `https`.
- **`HTTPHeader`**: Struct representing a single HTTP header field and value.
- **`HTTPContentType`**: Enum for common content types (e.g., `.json`, `.formURLEncoded`).
- **`HTTPAuthorization`**: Abstraction for various authorization schemes (e.g., `.bearer(token:)`).

### 3.4. `ResponseData`
A container for the `HTTPURLResponse` and the raw `Data` returned from a request, providing a unified way to inspect metadata and body content.

---

## 4. Technical Specifications

### 4.1. Error Handling
Pigeon uses a centralized `PigeonError` enum:
- `.invalidURL`: Thrown when URL components cannot form a valid URL.
- `.responseError(response:body:)`: Thrown for non-2xx status codes, capturing both the response metadata and the error body for debugging.

### 4.2. Concurrency Model
All network operations are performed using `async/await`, ensuring non-blocking execution and clear call sites. The library relies on `URLSession`'s internal concurrency management.

### 4.3. Data Persistence & State
Pigeon does not implement its own persistence layer. It is designed to be the networking bridge that feeds data into other layers (like CoreData, SwiftData, or simple in-memory models).

---

## 5. Interactions & API Design

### Request Flow
1. **Configuration:** Initialize a `Pigeon` with a host and base path.
2. **Path Construction:** Use `URLPath` to define the endpoint.
3. **Execution:** Call `request(_:path:queryItems:body:)`.
4. **Processing:**
   - For `Decodable` requests: Pigeon automatically decodes the response body into the specified type.
   - For raw requests: Pigeon returns `ResponseData`.

### Internal/External APIs
Pigeon is primarily a consumer of **REST APIs**. It generates standard `URLRequest` objects and processes `HTTPURLResponse` objects.

---

## 6. Testing Infrastructure

### Unit Testing
The project uses `XCTest`. Tests are located in `Tests/PigeonTests` and focus on:
- URL construction logic.
- Path joining and encoding.
- Header injection.
- Encoding/Decoding behavior.

### Integration Testing
Test models like `Pokemon` and `User` are used to verify real-world serialization scenarios against mock or live endpoints.

---

## 7. Security, Scalability, & Performance

- **Security:** Support for various `HTTPAuthorization` methods. By leveraging `URLSession`, Pigeon inherits system-level security features like App Transport Security (ATS) and certificate pinning (via `URLSessionDelegate`).
- **Scalability:** The library is stateless and lightweight, making it suitable for high-concurrency environments.
- **Performance:** Minimal overhead is introduced over raw `URLSession`. Efficient use of `Codable` and Swift's native networking stack ensures optimal performance.
