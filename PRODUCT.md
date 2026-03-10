I will read the `README.md`, `DESIGN.md`, and `Package.swift` files to understand the project's vision, design principles, and technical scope.
# Product Document: Pigeon

Pigeon is a lightweight, type-safe networking library for Swift designed to modernize and simplify how developers interact with RESTful APIs. By providing a clean abstraction over `URLSession` and fully embracing Swift's `async/await` concurrency, Pigeon removes the boilerplate and cognitive load often associated with mobile and server-side networking.

## 1. Product Vision & Core Objectives
**Vision:** To become the default "featherweight" networking choice for Swift developers who prioritize type safety, readability, and modern language features over the complexity of heavy-duty frameworks.

### Core Objectives:
- **Developer Velocity:** Minimize the code required to define and execute API requests.
- **Compile-Time Safety:** Leverage Swift’s type system to catch URL construction and serialization errors at compile time.
- **Modernity:** Provide a first-class experience for `async/await` and `Codable` without legacy baggage.
- **Platform Agnostic:** Ensure seamless operation across iOS, macOS, and Linux.

---

## 2. Target Audience & User Personas
Pigeon is built for Swift engineers who find `URLSession` too verbose but find libraries like Alamofire too heavy or complex for their needs.

### User Personas:
- **The "Swift Native" Developer:** Wants a library that feels like a natural extension of the Swift standard library, using modern patterns like structured concurrency.
- **The Indie Developer:** Needs to rapidly prototype apps with a reliable networking layer that "just works" with minimal configuration.
- **The Modular Architect:** Building a multi-module app and needs a tiny, dependency-free networking utility that can be embedded in internal frameworks without bloating the binary.

---

## 3. Feature Roadmap

### Short-Term (Completed / Current)
- [x] Full `async/await` integration for all requests.
- [x] Type-safe `Encodable` request bodies and `Decodable` response parsing.
- [x] Expressive `URLPath` system for safe URL construction.
- [x] Common authentication schemes (Bearer, Basic).
- [x] Customization of `JSONEncoder`/`JSONDecoder` and `URLSession`.

### Medium-Term (Milestone 1.5)
- **Interceptors:** A middleware system for logging, request signing, and global header injection.
- **Automatic Retries:** Configurable retry logic with exponential backoff for flaky connections.
- **Multipart Support:** Native support for uploading files and multi-part form data.
- **Combine Compatibility:** Optional publishers for projects still utilizing Reactive patterns.

### Long-Term (Milestone 2.0+)
- **Plugin Ecosystem:** Community-driven plugins for OAuth2 flows, Firebase integration, etc.
- **WebSocket Support:** Extending the type-safe philosophy to real-time communication.
- **Mocking Engine:** Built-in utilities for generating type-safe mocks for unit testing without a network connection.

---

## 4. Feature Prioritization
Our prioritization is driven by the **"Code that Reads Like Prose"** philosophy.
1. **Type Safety (Critical):** If a feature doesn't improve safety or reduce runtime crashes, it is deprioritized.
2. **Ergonomics (High):** How many lines of code does a developer need to write? We prioritize features that reduce "glue code."
3. **Performance (Medium):** While we aim for low overhead, we prioritize a clean API over micro-optimizations that would sacrifice readability.

---

## 5. Iteration & Experimentation Strategy
Pigeon is developed with a **"Test-First, Feedback-Always"** mindset.
- **Usage-Driven Design:** We implement new features by first writing the "ideal" call site in a test case, then building the underlying logic to support it.
- **Dogfooding:** The library is used in real-world applications by the core team to identify friction points in real-world networking scenarios (e.g., handling inconsistent API error formats).
- **RFC Process:** Significant architectural changes are proposed as "Design Proposals" in GitHub Discussions to gather community input before implementation.

---

## 6. Release Strategy & Onboarding
- **Semantic Versioning:** Strict adherence to SemVer to ensure stability for enterprise users.
- **The "5-Minute Success" Goal:** A new user should be able to add the package and make their first successful, type-safe GET request in under 5 minutes.
- **Documentation:** Every public API must be documented with inline Swift-Doc and accompanied by a practical example in the README.

---

## 7. Success Metrics (KPIs)
- **Time to First Request:** The average time it takes for a developer to integrate Pigeon and fetch data.
- **Adoption Rate:** Monthly growth in Swift Package Index mentions and GitHub stars.
- **API Surface Stability:** Minimizing breaking changes across major versions to maintain developer trust.
- **Binary Footprint:** Keeping the compiled size of the library under a specific threshold (e.g., < 200KB).

---

## 8. Future Opportunities
As the Swift ecosystem evolves (e.g., Swift 6 Data Isolation), Pigeon is positioned to become the leading networking library for **Strict Concurrency**. We see future growth in providing specialized "Pigeon-Pro" modules for niche requirements like gRPC or GraphQL, while keeping the core library slim and focused on REST.
