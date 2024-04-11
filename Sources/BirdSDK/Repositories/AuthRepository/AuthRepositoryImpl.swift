import Foundation

final class AuthRepositoryImpl: AuthRepository {
    
    private let httpClient: HttpClient
    private let storage: Storage
    private let authSemaphore = DispatchSemaphore(value: 0) // to prevent concurrent authorizations
    private let authQueue = DispatchQueue(label: "com.birdsdk.authQueue")
    
    init(httpClient: HttpClient = HttpClientImpl(), storage: Storage = StorageImpl()) {
        self.httpClient = httpClient
        self.storage = storage
    }
    
    func authIfNeeded(apiKey: String?, completion: @escaping CompletionBlock<Void>) {
        authQueue.async { [weak self] in
            guard let self = self else { return }
            guard let apiKey else {
                BirdLogger.log(msg: "No API key provided. Make sure you set API key by calling `setApiKey` method of BirdSDK")
                completion(.failure(.apiKeyIsMissing))
                return
            }
            
            guard storage.authToken == nil else {
                BirdLogger.log(msg: "Found auth token. Skipping authentication")
                completion(.success(Void()))
                return
            }
            
            BirdLogger.log(msg: "Loggin in...")
            httpClient.send(request: .auth(apiKey: apiKey)) { (result: Result<AuthResponse, BirdSDKError>) in
                switch result {
                case .success(let authResponse):
                    BirdLogger.log(msg: "Authorized")
                    self.storeAccessToren(response: authResponse)
                    completion(.success(Void()))
                case .failure(let error):
                    BirdLogger.log(msg: "Failed to authorize. Error: \(error.message)")
                    completion(.failure(error))
                }
                
                self.authSemaphore.signal()
            }
            
            authSemaphore.wait()
        }
    }
    
    private func storeAccessToren(response: AuthResponse) {
        storage.authToken = response.accessToken
        storage.refreshToken = response.refreshToken
    }
}
