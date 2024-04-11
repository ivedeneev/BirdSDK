import Foundation

struct AuthResponse: Codable, Equatable {
    let accessToken: String
    let refreshToken: String?
}
