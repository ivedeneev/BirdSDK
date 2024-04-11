# BirdSDK

Bird SDK sends user's location to Bird's server. It can location both periodically with given interval and on demand.

## Installation
Add the following line to your `Package.swift`

```
.package(url: "https://github.com/ivedeneev/BirdSDK", branch: "main")
```

## Usage

### Setup
```swift
BirdSDK.shared.setApiKey(apiKey: "api_key")
BirdSDK.verbose = true // set true to be able to see logs of SDK. Default is false. Do not use it in production!
```

### Periodic locations update

```swift
BirdSDK.shared.startUpdatingLocation(interval: 3) // select locations update
```

### Manual locations update
```swift
BirdSDK.shared.manuallyUpdateLocation { result in
    print(result)
}
/// or ///
try await BirdSDK.shared.manuallyUpdateLocation() // Note, that manual locations update method also supports async/await
```

# (For reviewer) Limitations / assumptions:

- SDK supports aync/await but implemented using callbacks to support earlier versions of iOS.
- User must provide locations update interval. Default update interval is also provided (30 min)
- Authorization process is hidden from the users of SDK. And happens 'automatically'
- No 'logging out' but periodic location updates could be stopped
- Periodic updates are stopped in case of client errors because that would mean that SDK is broken and this error is unrecoverable. It wourld be stopped in case of network errors
- CLLocationManager errors are not handled
- Some parts of SDK implemented 'naively' to save time; unit tests coverage is not complete for the same reason
- If user explicitly denied location it is treated as a regular unhappy flow without any special promt
- Network Requests cancellation is not handled

## To add in production
- Docs in `.docc` format
- Cocoapods support
- More detailed errors
- GitHub Actions


