import Foundation

public struct BirdSDKError: Error {
    public let code: Code
    public let message: String
    
    public enum Code: String {
        case decoding
        case request
        case network
        case client
    }

    static var apiKeyIsMissing = BirdSDKError(code: .client, message: "API key is missing")
    static var unknown = BirdSDKError(code: .network, message: "Unknown error")
}
