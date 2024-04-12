# BirdSDK

Bird SDK sends user's location to Bird's server. It can location both periodically with given interval and on demand.

## Installation
Add the following line to your `Package.swift` or add it manually via Xcode

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

- Concurrent authorizations are not allowed (concurrent refresh is allowed)
- SDK implemented using callbacks to support earlier versions of iOS. (async/await is supported though)
- User must provide locations update interval. Default update interval is also provided (30 min)
- Authorization process is hidden from the users of SDK. This is discussable depending on business case
- No 'logging out' but periodic location updates could be stopped (Depending on business case it could be added)
- Periodic updates are stopped in case of client errors because that would mean that SDK is most likely broken and this error is unrecoverable. It wouldnt be stopped in case of network errors
- CLLocationManager errors are not handled
- Some parts of SDK implemented 'naively' to save time; unit tests coverage is not complete for the same reason
- If user explicitly denied location it is treated as a regular unhappy flow without any special promt
- Network Requests cancellation is not handled
- Manual location updates doesnt trigger delegate (up to discussion)

## To add in production
- Docs in `.docc` format
- Cocoapods support
- More detailed errors
- GitHub Actions
- Work in background if needed (perhaps, leveraging silent push notifications)


