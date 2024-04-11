import Foundation
import CoreLocation

final class LocationMananagerImpl: NSObject, LocationManager {
    var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    private let locationManager: CLLocationManager
    private var getLocationCompletion: ((CLLocationCoordinate2D) -> Void)?
    private var permissionCompletion: ((Bool) -> Void)?
    
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        permissionCompletion = nil
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            permissionCompletion = completion
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            completion(false)
            break
        case .denied:
            // go to settings
            completion(false)
            break
        default:
            completion(true)
        }
    }
    
    func requestLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        locationManager.requestLocation()
        getLocationCompletion = completion
    }
}

extension LocationMananagerImpl: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        getLocationCompletion?(location.coordinate)
        getLocationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        permissionCompletion?(status == .authorizedWhenInUse)
        permissionCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: handle errors.
        BirdLogger.log(msg: error.localizedDescription)
    }
}
