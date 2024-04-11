import Foundation

struct AuthResponse: Decodable {
    let accessToken: String
    let expiresAt: String
    let refreshToken: String?
}
