import Foundation
import CoreLocation

protocol LocationManager {
    var locationServicesEnabled: Bool { get }
    
    func requestPermission(completion: @escaping (Bool) -> Void)
    func requestLocation(completion: @escaping (CLLocationCoordinate2D) -> Void)
}
