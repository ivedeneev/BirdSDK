import Foundation

final class RequestBuilderImpl: RequestBuilder {
    
    private let storage: Storage
    
    init(storage: Storage = StorageImpl()) {
        self.storage = storage
    }
    
    func urlRequest(for request: Request) throws -> URLRequest {
        let baseUrl = URL(string: "https://dummy-api-mobile.api.sandbox.bird.one")
        guard let url = URL(string: request.path, relativeTo: baseUrl) else {
            throw BirdSDKError(code: .request, message: "Incorrect URL")
        }
        
        do {
            let mutableURLRequest = NSMutableURLRequest(url: url)
            mutableURLRequest.httpMethod = request.httpMethod.rawValue
            mutableURLRequest.httpBody = try JSONSerialization.data(withJSONObject: request.parameters)
            
            if let token = storage.authToken {
                mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            request.headers.forEach { key, value in
                mutableURLRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            return mutableURLRequest as URLRequest
        } catch {
            throw BirdSDKError(code: .request, message: "Bad parameters")
        }
    }
}
