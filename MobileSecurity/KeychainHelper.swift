import Security
import CryptoKit
import Foundation

class KeychainHelper {
    static let shared = KeychainHelper()
    private let keychainService = "com.assessment.encryptionKey"
    private let keychainAccount = "encryptionKeyAccount"

    func saveKey(_ key: SymmetricKey) -> Bool {
        if retrieveKey() != nil {
            // Key already exists, no need to save it again
            return true
        }
        
        let keyData = key.withUnsafeBytes { Data(Array($0)) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData
        ]
        
        SecItemDelete(query as CFDictionary) // Remove any existing key
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieveKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let keyData = item as? Data else {
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
}
