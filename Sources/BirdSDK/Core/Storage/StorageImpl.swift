import Foundation

private let ITEM_IS_EXISTS_STATUS_CODE = -25299
private let authTokenKey = "com.birdsdk.authTokenKey"
private let refreshTokenKey = "com.birdsdk.refreshTokenKey"


// Naive implementation of storage using Keychain
final class StorageImpl: Storage {
    
    var authToken: String? {
        get {
            getString(for: authTokenKey)
        }
        
        set {
            set(value: newValue, key: authTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            getString(for: refreshTokenKey)
        }
        
        set {
            set(value: newValue, key: refreshTokenKey)
        }
    }
    
    private func set(value: String?, key: String) {
        var status: Int32 = -999999
        
        guard let codeData = value?.data(using: .utf8) else {
            let query = [
                 kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: key as CFString
            ] as CFDictionary

            status = SecItemDelete(query)
            
            return
        }
        
        let keychainItemQuery = [
                kSecAttrAccount: key as CFString,
                kSecValueData: codeData,
                kSecClass: kSecClassGenericPassword
            ] as CFDictionary

        status = SecItemAdd(keychainItemQuery, nil)
        
        if status == ITEM_IS_EXISTS_STATUS_CODE {
            let updateFields = [
                 kSecValueData: codeData
            ] as CFDictionary
            
            status = SecItemUpdate(keychainItemQuery, updateFields)
        }
    }
    
    private func getString(for key: String) -> String? {
        let keychainItem = [
            kSecAttrAccount: key as CFString,
             kSecClass: kSecClassGenericPassword,
             kSecReturnAttributes: true,
             kSecReturnData: true
         ] as CFDictionary
                
         var ref: AnyObject?

         SecItemCopyMatching(keychainItem, &ref)
         if let result = ref as? NSDictionary, let passwordData = result[kSecValueData] as? Data {
             let str = String(decoding: passwordData, as: UTF8.self)
             return str
         }
            
        return nil
    }
}
