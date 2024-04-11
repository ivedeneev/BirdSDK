import Foundation

final class HttpClientImpl: HttpClient {
    private let urlSession: URLSession
    private let storage: Storage
    private let requestBuilder: RequestBuilder
    
    init(
        urlSession: URLSession = .init(configuration: .default),
        storage: Storage = StorageImpl(),
        requestBuilder: RequestBuilder = RequestBuilderImpl()
    ) {
        self.urlSession = urlSession
        self.storage = storage
        self.requestBuilder = requestBuilder
    }
    
    func send<T: Decodable>(request: Request, allowRetry: Bool, completion: @escaping ((Result<T, BirdSDKError>) -> Void)) {
        do {
            let urlRequest = try requestBuilder.urlRequest(for: request)

            let task = urlSession.dataTask(with: urlRequest) { data, response, error in
                do {
                    if let error {
                        throw BirdSDKError(code: .network, message: error.localizedDescription)
                    }
                    
                    guard let response = response as? HTTPURLResponse, let data else {
                        throw BirdSDKError(code: .network, message: "Bad server response")
                    }
                    
                    let statusCode = response.statusCode
                    if 200..<300 ~= statusCode {
                        let data = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(data))
                    } else if statusCode == 403, allowRetry {
                        self.refreshToken(originalRequest: request, completion: completion)
                    } else if 400..<500 ~= statusCode {
                        let errorModel = try JSONDecoder().decode(BackendError.self, from: data)
                        throw BirdSDKError(code: .network, message: errorModel.error)
                    } else {
                        throw BirdSDKError(code: .network, message: String(data: data, encoding: .utf8) ?? "Unknown error")
                    }
                } catch is DecodingError {
                    completion(.failure(BirdSDKError(code: .network, message: "Error parsing response")))
                } catch let error as BirdSDKError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.unknown))
                }
            }
            
            task.resume()
        } catch let error as BirdSDKError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    private func refreshToken<T: Decodable>(
        originalRequest: Request,
        completion: @escaping ((Result<T, BirdSDKError>) -> Void))
    {
        guard let refreshToken = storage.refreshToken else {
            completion(.failure(BirdSDKError(code: .request, message: "No refresh token")))
            return
        }
        send(request: .refresh(refreshToken: refreshToken), allowRetry: false) { (result: Result<AuthResponse, BirdSDKError>) in
            switch result {
            case .success(let response):
                self.storage.authToken = response.accessToken
                self.send(request: originalRequest, allowRetry: false, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}