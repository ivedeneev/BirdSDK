import Foundation

enum HttpMethod: String {
    case post = "POST"
}

typealias CompletionBlock<T> = (Result<T, BirdSDKError>) -> Void

public struct EmptyResponse: Decodable {}
