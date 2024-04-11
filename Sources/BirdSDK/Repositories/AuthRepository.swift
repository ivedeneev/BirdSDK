import Foundation

protocol AuthRepository {
    func auth(apikey: String, completion: @escaping CompletionBlock<AuthResponse>)
}

final class AuthRepositoryImpl: AuthRepository {
    
    private let httpClient: HttpClient
    private let storage: Storage
    
    init(httpClient: HttpClient = HttpClientImpl(), storage: Storage = StorageImpl()) {
        self.httpClient = httpClient
        self.storage = storage
    }
    
    func auth(apikey: String, completion: @escaping CompletionBlock<AuthResponse>) {
        httpClient.send(request: .auth(apiKey: apikey)) { [weak self] (result: Result<AuthResponse, BirdSDKError>) in
            guard let self else { return }
            switch result {
            case .success(let authResponse):
                self.storage.authToken = authResponse.accessToken
                self.storage.refreshToken = authResponse.refreshToken
            case .failure(let error):
                break
            }
            
            completion(result)
        }
    }
}
