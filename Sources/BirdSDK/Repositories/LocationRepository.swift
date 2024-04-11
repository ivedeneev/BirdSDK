import Foundation
import CoreLocation

protocol LocationRepository {
    func startUpdatingLocation(interval: TimeInterval, didSend: @escaping CompletionBlock<EmptyResponse>)
    func stopUpdatingLocation()
    func updateLocation(latitude: Double, longtitude: Double, completion: @escaping CompletionBlock<EmptyResponse>)
}

final class LocationRepositoryImpl: LocationRepository {
    
    private let httpClient: HttpClient
    private let locationManager: LocationManager
    private var timer: Timer?
    
    init(
        httpClient: HttpClient = HttpClientImpl(),
        locationManager: LocationManager = LocationMananagerImpl()
    ) {
        self.httpClient = httpClient
        self.locationManager = locationManager
    }
    
    func startUpdatingLocation(interval: TimeInterval, didSend: @escaping CompletionBlock<EmptyResponse>) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            self?.getLocationAndSend(didSend: didSend)
        }
        
        getLocationAndSend(didSend: didSend)
        
        guard !Thread.isMainThread else { return }
        let runLoop = RunLoop.current
        runLoop.add(timer!, forMode: .default)
        runLoop.run()
    }
    
    func stopUpdatingLocation() {
        timer?.invalidate()
    }

    func updateLocation(latitude: Double, longtitude: Double, completion: @escaping CompletionBlock<EmptyResponse>) {
        httpClient.send(request: Request.sendLocation(lat: latitude, lon: longtitude), completion: completion)
    }
    
    private func getLocationAndSend(didSend: @escaping CompletionBlock<EmptyResponse>) {
        locationManager.getLocation { [weak self] loc in
            guard let self else { return }
            self.updateLocation(latitude: loc.latitude, longtitude: loc.longitude) { result in
                switch result {
                case .success:
                    didSend(.success(EmptyResponse()))
                case .failure(let error):
                    didSend(.failure(error))
                }
            }
        }
    }
}
