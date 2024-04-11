import Foundation

protocol Storage: AnyObject {
    var authToken: String? { get set }
    var refreshToken: String? { get set }
}
