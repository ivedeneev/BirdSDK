import XCTest
@testable import BirdSDK

final class MockURLSession: URLSessionProtocol {
    
    var result: (Data?, URLResponse?, Error?)?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        URLSessionDataTaskMock { [unowned self] in
            guard let result else {
                return
            }
            completionHandler(result.0, result.1, result.2)
        }
    }
    
    func setupResults<T: Encodable>(data: T?, statusCode: Int, error: Error?) {
        result = (
            try? JSONEncoder().encode(data),
            HTTPURLResponse(url: URL(string: "https://bird.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil),
            error
        )
    }
}

final class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }

    override func cancel() {
        closure()
    }
}
