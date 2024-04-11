# BirdSDK

Bird SDK sends user's location to Bird's server. It can location both periodically with given interval and on demand.

## Installation
BirdSDK is available via Swift Package Manager

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

# Notes to reviewer:

## Limitations / assumptions

- Authorization process is hidden from the users of SDK. And happens 'automatically'
- No 'logging out'
- If sending location to server fails it stops periodic updates, because most likely this error in unrecoverable and it doesnt make sence to continue
- 

