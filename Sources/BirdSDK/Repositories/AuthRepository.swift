import Foundation

protocol AuthRepository {
    func authIfNeeded(apiKey: String?, completion: @escaping CompletionBlock<Void>)
}

final class AuthRepositoryImpl: AuthRepository {
    
    private let httpClient: HttpClient
    private let storage: Storage
    
    init(httpClient: HttpClient = HttpClientImpl(), storage: Storage = StorageImpl()) {
        self.httpClient = httpClient
        self.storage = storage
        
        storage.authToken = nil
        storage.refreshToken = nil
    }
    
    func authIfNeeded(apiKey: String?, completion: @escaping CompletionBlock<Void>) {
        guard let apiKey else {
            BirdLogger.log(msg: "No API key provided. Make sure you set API key by calling `setApiKey` method of BirdSDK")
            completion(.failure(.apiKeyIsMissing))
            return
        }
        
        guard storage.authToken == nil else {
            BirdLogger.log(msg: "Skipping loggin in...")
            completion(.success(Void()))
            return
        }
        
        BirdLogger.log(msg: "Loggin in...")
        httpClient.send(request: .auth(apiKey: apiKey)) { [weak self] (result: Result<AuthResponse, BirdSDKError>) in
            guard let self else { return }
            switch result {
            case .success(let authResponse):
                self.storeAccessToren(response: authResponse)
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func storeAccessToren(response: AuthResponse) {
        storage.authToken = response.accessToken
        storage.refreshToken = response.refreshToken
    }
}
