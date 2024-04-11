@testable import BirdSDK

final class MockHttpClient: HttpClient {
    var result: Result<Any, BirdSDKError>?
    
    func send<T: Decodable>(request: Request, allowRetry: Bool, completion: @escaping (Result<T, BirdSDKError>) -> Void) {
        switch result {
        case .success(let success):
            if let data = success as? T {
                completion(.success(data))
            } else {
                fatalError("Mock data has incorrect type")
            }
            
        case .failure(let failure):
            completion(.failure(failure))
        case nil:
            fatalError("result didnt set")
        }
    }
}
