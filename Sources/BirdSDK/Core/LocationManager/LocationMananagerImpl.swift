import Foundation
import CoreLocation

final class LocationMananagerImpl: NSObject, LocationManager {
    var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    private let locationManager: CLLocationManager
    private var getLocationCompletion: ((CLLocationCoordinate2D) -> Void)?
    
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //TODO: throw an error?
            break
        case .denied:
            // go to settings
            break
        default:
            locationManager.requestLocation()
        }
    }
    
    func getLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        requestLocation()
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
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // более понятное описание ошибки
//        if let clError = error as? CLError {
//            switch clError.code {
//            case CLError.locationUnknown:
//                log("Неизвестная локация", type: .error)
//            case CLError.denied:
//                log("Доступ к локации запрещен", type: .error)
//            default:
//                log("Неизвестная ошибка", type: .error)
//            }
//        } else {
//            log("Неизвестная ошибка", type: .error)
//        }
    }
}
