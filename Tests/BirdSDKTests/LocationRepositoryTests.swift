import XCTest
@testable import BirdSDK

final class LocationRepositoryTests: XCTestCase {
    
    var sut: LocationRepositoryImpl!
    var httpClient: MockHttpClient!
    var storage: MockStorage!
    var locationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        
        httpClient = MockHttpClient()
        locationManager = MockLocationManager()
        storage = MockStorage()
        
        sut = LocationRepositoryImpl(
            httpClient: httpClient,
            locationManager: locationManager,
            storage: storage
        )
    }
    
    func test_WhenGotLocation_SendManualLocationSuccedds() {
        let exp = XCTestExpectation(description: #function)
        var expected: Result<Void, BirdSDKError>?
        
        httpClient.result = .success(EmptyResponse())
        locationManager.permissionGranted = true
        locationManager.currentLocation = .init(latitude: 1, longitude: 1)
        
        sut.sendLocation { result in
            expected = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.3)
        XCTAssertNotNil(try? expected?.get())
    }
    
    func test_WhenGotLocation_PeriodicLocationUpdatesFiresMoreThenOnce() {
        let exp = XCTestExpectation(description: #function)
        var timesFired = 0
        
        httpClient.result = .success(EmptyResponse())
        locationManager.permissionGranted = true
        locationManager.currentLocation = .init(latitude: 1, longitude: 1)
        
        let timeout: TimeInterval = 1
        let interval: TimeInterval = 0.2
        
        sut.sendLocation { result in
            XCTAssertNotNil(try? result.get())
        }
        
        sut.startSendingLocation(interval: interval) { result in
            timesFired += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout - interval) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
        XCTAssertTrue(timesFired > 1, timesFired.description)
    }
    
    func test_WhenNoLocationPermission_LocationDidntSent() {
        let exp = XCTestExpectation(description: #function)
        var expected: Result<Void, BirdSDKError>?
        
        httpClient.result = .success(EmptyResponse())
        locationManager.permissionGranted = false
        
        sut.sendLocation { result in
            expected = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.3)
        XCTAssertNil(try? expected?.get())
    }
}
