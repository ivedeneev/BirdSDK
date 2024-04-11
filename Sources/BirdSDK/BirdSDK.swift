// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol BirdSDKDelegate: AnyObject {
    func didSendLocationAutomatically(sdk: BirdSDK)
    func didFailToSendLocationAutomatically(sdk: BirdSDK, error: BirdSDKError)
}

public class BirdSDK {

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
    
    public func startUpdatingLocation(interval: TimeInterval) {
        authIfNeeded { [weak self] in
            self?.locationRepository.startUpdatingLocation(interval: interval) { (result: Result<Void, BirdSDKError>) in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let success = (try? result.get()) != nil
                    BirdLogger.log(msg: "Sent location. Success: \(success)")
                    switch result {
                    case .success:
                        self.delegate?.didSendLocationAutomatically(sdk: self)
                    case .failure(let error):
                        self.delegate?.didFailToSendLocationAutomatically(sdk: self, error: error)
                    }
                }
            }
        }
    }
    
    public func updateLocation(completion: @escaping (Result<Void, BirdSDKError>) -> Void) {
        authIfNeeded { [weak self] in
            self?.locationRepository.updateLocation { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    public func stopUpdatingLocation() {
        locationRepository.stopUpdatingLocation()
    }
    
    private func authIfNeeded(completion: @escaping () -> Void) {        
        authRepository.authIfNeeded(apiKey: apiKey) { result in
            switch result {
            case .success:
                completion()
            case .failure(let error):
                BirdLogger.log(msg: "Authorization failed. \(error.message)")
                break
            }
        }
    }
}

@available(iOS 13.0.0, *)
public extension BirdSDK {
    func updateLocation() async throws {
        _ = try await withCheckedThrowingContinuation { continuation in
            updateLocation { result in
                continuation.resume(with: result)
            }
        }
    }
}
