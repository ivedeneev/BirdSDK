import Foundation
@testable import BirdSDK

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

final class MockURLSession: URLSessionProtocol {
    
    var result: (Data?, URLResponse?, Error?)!
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        URLSessionDataTaskMock { [unowned self] in
            completionHandler(self.result.0, self.result.1, self.result.2)
        }
    }
    
    func setupResults<T: Encodable>(data: T?, statusCode: Int, error: Error?) {
        result = (
            try? JSONEncoder().encode(data),
            HTTPURLResponse(url: URL(string: "https://google.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil),
            error
        )
    }
}
