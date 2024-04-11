import Foundation
import CoreLocation

protocol LocationManager {
    var locationServicesEnabled: Bool { get }
    func requestLocation()
    func getLocation(completion: @escaping (CLLocationCoordinate2D) -> Void)
}
