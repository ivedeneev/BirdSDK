import Foundation

final class LocationRepositoryImpl: LocationRepository {
    
    private let httpClient: HttpClient
    private let locationManager: LocationManager
    private var timer: Timer?
    private let storage: Storage
    private let locationQueue = DispatchQueue(label: "com.birdsdk.location")
    
    init(
        httpClient: HttpClient = HttpClientImpl(),
        locationManager: LocationManager = LocationMananagerImpl(),
        storage: Storage = StorageImpl()
    ) {
        self.httpClient = httpClient
        self.locationManager = locationManager
        self.storage = storage
    }
    
    func startSendingLocation(interval: TimeInterval, didSend: @escaping CompletionBlock<Void>) {
        guard timer == nil else {
            BirdLogger.log(msg: "Periodic location updates are already in progress. Ignoring...")
            return
        }
        
        locationQueue.async { [weak self] in
            guard let self else { return }
            
            self.locationManager.requestPermission { granted in
                guard granted else {
                    let error = BirdSDKError(code: .client, message: "Location permission are denied")
                    BirdLogger.log(error: error)
                    didSend(.failure(error))
                    return
                }
                
                self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                    self.privateUpdateLocation(completion: didSend)
                }
                
                if let timer = self.timer, !Thread.isMainThread {
                    RunLoop.current.add(timer, forMode: .default)
                    RunLoop.current.run()
                }
                
                self.privateUpdateLocation { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        guard error.code != .network else { break }
                        self.stopSendingLocation()
                    }
                    didSend(result)
                }
            }
        }
    }
    
    func sendLocation(completion: @escaping CompletionBlock<Void>) {
        locationQueue.async { [weak self] in
            guard let self else { return }
            self.locationManager.requestPermission { granted in
                guard granted else {
                    let error = BirdSDKError(code: .client, message: "Location permission are denied")
                    BirdLogger.log(error: error)
                    completion(.failure(error))
                    return
                }
                
                self.privateUpdateLocation(completion: completion)
            }
        }
    }
    
    private func privateUpdateLocation(completion: @escaping CompletionBlock<Void>) {
        locationManager.requestLocation { [weak self] loc in
            guard let self else { return }
            
            let request = Request.sendLocation(lat: loc.latitude, lon: loc.longitude)
            BirdLogger.log(msg: "Sending location: \(loc.latitude) \(loc.longitude)")
            self.httpClient.send(request: request) { (result: Result<EmptyResponse, BirdSDKError>) in
                let success = (try? result.get()) != nil
                BirdLogger.log(msg: "Sent location. Success: \(success)")
                switch result {
                case .success:
                    completion(.success(Void()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func stopSendingLocation() {
        timer?.invalidate()
        timer = nil
    }
}
