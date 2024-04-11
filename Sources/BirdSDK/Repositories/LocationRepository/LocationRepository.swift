import Foundation

protocol LocationRepository {
    func startSendingLocation(interval: TimeInterval, didSend: @escaping CompletionBlock<Void>)
    func stopSendingLocation()
    func sendLocation(completion: @escaping CompletionBlock<Void>)
}
