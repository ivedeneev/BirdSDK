import Foundation
@testable import BirdSDK

final class MockStorage: Storage {
    var authToken: String?
    var refreshToken: String?
}
