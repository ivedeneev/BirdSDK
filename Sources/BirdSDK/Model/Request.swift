import Foundation

enum Request {
    case auth(apiKey: String)
    case refresh(refreshToken: String)
    case sendLocation(lat: Double, lon: Double)
    
    var path: String {
        switch self {
        case .sendLocation:
            "location"
        case .auth:
            "auth"
        case .refresh:
            "auth/refresh"
        }
    }
    
    var httpMethod: HttpMethod {
        .post
    }
    
    var parameters: [String : Any] {
        switch self {
        case .sendLocation(let lat, let lon):
            ["latitude": lat, "longitude" : lon]
        case .auth, .refresh:
            [:]
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .auth(let apiKey):
            ["Authorization" : "Bearer \(apiKey)"]
        case .refresh(let refreshToken):
            ["Authorization" : "Bearer \(refreshToken)"]
        default:
            [:]
        }
    }
}
