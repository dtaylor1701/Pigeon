# Pigeon
![Tests](https://github.com/dtaylor1701/Pigeon/workflows/Test/badge.svg)

A super thin layer above URLSession which handles a bit of configuration and boiler plate. Also leverages `Codable` types and type inference for a concise API.


Example:

```swift
let stuffService = Service(host: "stuff.com")

func getStuff() async throws -> Stuff {
    try await stuffService.request(.get, "stuff")
}
```

Only JSON encoding and decoding is supported at the moment, although methods for dealing with the request and response as `Data` are available.

This exists in sort of an implement-as-needed state, so expect many limitations!
