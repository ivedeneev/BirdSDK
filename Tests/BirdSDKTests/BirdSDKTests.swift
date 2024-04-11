import XCTest
import CoreLocation
@testable import BirdSDK

final class BirdSDKTests: XCTestCase {
    
    var sut: LocationRepositoryImpl!
    var auth: AuthRepositoryImpl!
    var locationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        locationManager = MockLocationManager()
        sut = LocationRepositoryImpl(locationManager: locationManager)
        auth = AuthRepositoryImpl()
    }
    
    func testAuth() {
        let exp = XCTestExpectation(description: #function)
        auth.auth(apikey: "xdk8ih3kvw2c66isndihzke5") { result in
            print(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2)
    }
    
//    func testRefresh() {
//        let exp = XCTestExpectation(description: #function)
//        auth.auth(apikey: "xdk8ih3kvw2c66isndihzke5") { [self] _ in
//            auth.refresh() { result in
//                print(result)
//                exp.fulfill()
//            }
//        }
//        
//        wait(for: [exp], timeout: 20)
//    }
    
    func testSendLocation() {
        let exp = XCTestExpectation(description: #function)
        auth.auth(apikey: "xdk8ih3kvw2c66isndihzke5") { [self] _ in
            sut.updateLocation(latitude: 43, longtitude: 43) { result in
                print(result)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 2)
    }
    
    func testPeriodicLocationsUpdate() {
        let exp = XCTestExpectation(description: #function)
        auth.auth(apikey: "xdk8ih3kvw2c66isndihzke5") { [self] _ in
            sut.startUpdatingLocation(interval: 1) { _ in
                
            }
        }
        
        wait(for: [exp], timeout: 20)
    }
}


final class MockLocationManager: LocationManager {
    
    var currentLocation: CLLocationCoordinate2D = .init(latitude: 37, longitude: 55)
    
    var locationServicesEnabled: Bool {
        true
    }
    
    func requestLocation() {
        
    }
    
    func getLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        completion(currentLocation)
    }
}
