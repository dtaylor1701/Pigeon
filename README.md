# Pigeon

A super thin layer above URLSession which handles a bit of configuration and boiler plate. Also leverages `Codable` types and type inference for a pretty concise API.


Example:

```swift
let stuffService = Service(host: "stuff.com")

func getStuff() async throws -> Stuff {
    try await stuffService.request(.get, "stuff")
}
```
