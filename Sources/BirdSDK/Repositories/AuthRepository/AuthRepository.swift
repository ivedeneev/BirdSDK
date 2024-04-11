import Foundation

protocol AuthRepository {
    func authIfNeeded(apiKey: String?, completion: @escaping CompletionBlock<Void>)
}
