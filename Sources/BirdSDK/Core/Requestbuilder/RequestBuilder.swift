import Foundation

protocol RequestBuilder {
    func urlRequest(for request: Request) throws -> URLRequest
}
