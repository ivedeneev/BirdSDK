import CoreLocation
@testable import BirdSDK

final class MockLocationManager: LocationManager {
    var currentLocation: CLLocationCoordinate2D = .init(latitude: 37, longitude: 55)
    var permissionGranted = true
    
    var locationServicesEnabled: Bool {
        true
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        completion(permissionGranted)
    }
    
    func requestLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        completion(currentLocation)
    }
}
