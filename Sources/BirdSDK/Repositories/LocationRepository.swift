import Foundation
import CoreLocation

protocol LocationRepository {
    func startUpdatingLocation(interval: TimeInterval, didSend: @escaping CompletionBlock<Void>)
    func stopUpdatingLocation()
    func updateLocation(completion: @escaping CompletionBlock<Void>)
}

final class LocationRepositoryImpl: LocationRepository {
    
    private let httpClient: HttpClient
    private let locationManager: LocationManager
    private var timer: Timer?
    private let storage: Storage
    
    init(
        httpClient: HttpClient = HttpClientImpl(),
        locationManager: LocationManager = LocationMananagerImpl(),
        storage: Storage = StorageImpl()
    ) {
        self.httpClient = httpClient
        self.locationManager = locationManager
        self.storage = storage
    }
    
    func startUpdatingLocation(interval: TimeInterval, didSend: @escaping CompletionBlock<Void>) {
        locationManager.requestPermission { [weak self] granted in
            guard granted else {
                BirdLogger.log(msg: "Location permission got denied")
                return
            }
            
            guard let self else { return }
            
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
                self?._updateLocation(completion: didSend)
            }
            
            _updateLocation(completion: didSend)
            
            guard !Thread.isMainThread else { return }
            let runLoop = RunLoop.current
            runLoop.add(timer!, forMode: .default)
            runLoop.run()
        }
    }
    
    func updateLocation(completion: @escaping CompletionBlock<Void>) {
        locationManager.requestPermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                let error = BirdSDKError(code: .client, message: "Location permission got denied")
                BirdLogger.log(error: error)
                completion(.failure(error))
                return
            }
            
            self._updateLocation(completion: completion)
        }
    }
    
    private func _updateLocation(completion: @escaping CompletionBlock<Void>) {
        locationManager.requestLocation { [weak self] loc in
            guard let self else { return }
            
            let request = Request.sendLocation(lat: loc.latitude, lon: loc.longitude)
            BirdLogger.log(msg: "Sending location: \(loc.latitude) \(loc.longitude)")
            self.httpClient.send(request: request) { (result: Result<EmptyResponse, BirdSDKError>) in
                switch result {
                case .success:
                    completion(.success(Void()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func stopUpdatingLocation() {
        timer?.invalidate()
    }
}
