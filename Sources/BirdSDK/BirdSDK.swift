// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol BirdSDKDelegate: AnyObject {
    func didSendLocationAutomatically(sdk: BirdSDK)
    func didFailToSendLocationAutomatically(sdk: BirdSDK, error: BirdSDKError)
}

public class BirdSDK {

    static public var isDebug: Bool = false
    
    public weak var delegate: BirdSDKDelegate?
    
    private let apiKey: String
    private let locationRepository: LocationRepository
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.locationRepository = LocationRepositoryImpl()
    }
    
    func login() {
        
    }
    
    public func startUpdatingLocation(interval: TimeInterval) {
        locationRepository.startUpdatingLocation(interval: interval) { (result: Result<EmptyResponse, BirdSDKError>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    self.delegate?.didSendLocationAutomatically(sdk: self)
                case .failure(let error):
                    self.delegate?.didFailToSendLocationAutomatically(sdk: self, error: error)
                }
            }
        }
    }
    
    public func stopUpdatingLocation() {
        locationRepository.stopUpdatingLocation()
    }
    
    public func updateLocation(latitude: Double, longtitude: Double, completion: @escaping (Result<EmptyResponse, BirdSDKError>) -> Void) {
        locationRepository.updateLocation(latitude: latitude, longtitude: longtitude) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

@available(iOS 13.0.0, *)
extension BirdSDK {
    func updateLocation(latitude: Double, longtitude: Double) async throws {
        _ = try await withCheckedThrowingContinuation { continuation in
            updateLocation(latitude: latitude, longtitude: longtitude) { result in
                continuation.resume(with: result)
            }
        }
    }
}
