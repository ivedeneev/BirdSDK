// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol BirdSDKDelegate: AnyObject {
    func didSendLocationAutomatically(sdk: BirdSDK)
    func didFailToSendLocationAutomatically(sdk: BirdSDK, error: BirdSDKError)
}

public class BirdSDK {
    
    /// Enables or disabled logs in SDK. Default is false
    public static var verbose: Bool = false {
        didSet {
            BirdLogger.verbose = verbose
        }
    }
    
    public weak var delegate: BirdSDKDelegate?
    public static let shared = BirdSDK()
    
    private var apiKey: String?
    private let locationRepository: LocationRepository
    private let authRepository: AuthRepository
    
    init() {
        self.locationRepository = LocationRepositoryImpl()
        self.authRepository = AuthRepositoryImpl()
    }
    
    public func setApiKey(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Caputture user location and send it to server with given interval
    /// - Parameter interval: send interval in seconds
    public func startUpdatingLocation(interval: TimeInterval) {
        authIfNeeded { [weak self] in
            self?.locationRepository.startSendingLocation(interval: interval) { (result: Result<Void, BirdSDKError>) in
                DispatchQueue.main.async { [weak self] in
                    self?.obtainPeriodicLocationUpdateResult(result: result)
                }
            }
        }
    }
    
    /// Manually request and send location to the server
    /// - Parameter completion: completion handler
    public func manuallyUpdateLocation(completion: @escaping (Result<Void, BirdSDKError>) -> Void) {
        authIfNeeded { [weak self] in
            self?.locationRepository.sendLocation { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    public func stopUpdatingLocation() {
        locationRepository.stopSendingLocation()
    }
    
    private func authIfNeeded(completion: @escaping () -> Void) {
        authRepository.authIfNeeded(apiKey: apiKey) { [weak self] result in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                BirdLogger.log(msg: "Authorization failed. \(error.message)")
                break
            }
        }
    }
    
    private func obtainPeriodicLocationUpdateResult(result: Result<Void, BirdSDKError>) {
        switch result {
        case .success:
            delegate?.didSendLocationAutomatically(sdk: self)
        case .failure(let error):
            delegate?.didFailToSendLocationAutomatically(sdk: self, error: error)
        }
    }
}

@available(iOS 13.0.0, *)
public extension BirdSDK {
    func manuallyUpdateLocation() async throws {
        _ = try await withCheckedThrowingContinuation { continuation in
            manuallyUpdateLocation { result in
                continuation.resume(with: result)
            }
        }
    }
}
