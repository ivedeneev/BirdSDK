import Foundation

protocol HttpClient {
    func send<T: Decodable>(request: Request, allowRetry: Bool, completion: @escaping (Result<T, BirdSDKError>) -> Void)
}

extension HttpClient {
    func send<T: Decodable>(request: Request, allowRetry: Bool = true, completion: @escaping (Result<T, BirdSDKError>) -> Void) {
        send(request: request, allowRetry: allowRetry, completion: completion)
    }
}
