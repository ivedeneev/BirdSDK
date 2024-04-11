import Foundation

// Naive implementation of logger
final class BirdLogger {
    static var verbose = false
    
    private init() {}
    
    static func log(msg: String) {
        guard verbose else { return }
        print("BirdSDK: [\(Date())] \(msg)")
    }
    
    static func log(error: BirdSDKError) {
        guard verbose else { return }
        print("BirdSDK: [\(Date())] \(error.message)")
    }
}
