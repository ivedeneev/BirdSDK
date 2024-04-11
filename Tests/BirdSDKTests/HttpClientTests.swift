import XCTest
@testable import BirdSDK

final class HttpClientTests: XCTestCase {
    
    var urlSession: MockURLSession!
    var storage: MockStorage!
    var sut: HttpClientImpl!
    
    override func setUp() {
        super.setUp()
        urlSession = MockURLSession()
        storage = MockStorage()
        sut = HttpClientImpl(urlSession: urlSession, storage: storage)
    }
    
    func testSendRequest() {
        let exp = XCTestExpectation(description: #function)
        
        let expected = AuthResponse(accessToken: "1", refreshToken: "1")
        urlSession.setupResults(data: expected, statusCode: 200, error: nil)
        
        sut.send(request: .auth(apiKey: ""), allowRetry: true) { (result: Result<AuthResponse, BirdSDKError>) in
            switch result {
            case .success(let success):
                XCTAssertEqual(success, expected)
            case .failure(let failure):
                XCTFail(failure.message)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.5)
    }
}
