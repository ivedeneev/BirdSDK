import Foundation
import CoreLocation

final class LocationMananagerImpl: NSObject, LocationManager {
    var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    private let locationManager: CLLocationManager
    
    private var locationCompletions = Array<((CLLocationCoordinate2D) -> Void)>()
    private var locationsLock = NSLock()
    
    private var permissionCompletions = Array<((Bool) -> Void)>()
    private var permissionsLock = NSLock()
    
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        guard locationServicesEnabled else {
            BirdLogger.log(msg: "Location services are not enabled")
            completion(false)
            return
        }
        
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            permissionsLock.withLock {
                locationManager.requestWhenInUseAuthorization()
                permissionCompletions.append(completion)
            }
        case .restricted:
            completion(false)
            break
        case .denied:
            BirdLogger.log(msg: "User explicitly denied location permissions. You might want to show ")
            completion(false)
            break
        default:
            completion(true)
        }
    }
    
    func requestLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        locationsLock.withLock {
            locationManager.requestLocation()
            locationCompletions.append(completion)
        }
    }
}

extension LocationMananagerImpl: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        locationsLock.withLock {
            locationCompletions.forEach { $0(location.coordinate) }
            locationCompletions.removeAll()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        
        permissionsLock.withLock {
            permissionCompletions.forEach { $0(status == .authorizedWhenInUse) }
            permissionCompletions.removeAll()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: handle errors
        BirdLogger.log(msg: error.localizedDescription)
    }
}
