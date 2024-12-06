//
//  KeychainHelper.swift
//  IceWarp
//
//  Created by Ajay on 05/12/24.
//

import Foundation
import Security

// MARK: - Keychain Helper
final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    // Constants
    private let _kSecAttrAccount = "userToken"
    private let keychainQueue = DispatchQueue(label: "com.keychain.helper.queue", attributes: .concurrent)
    
    // Saves a token securely in the Keychain.
    func saveToken(token: String?) {
        // Convert token to Data
        guard let data = token?.data(using: .utf8) else {
            print("Failed to convert token to data")
            return
        }
        
        keychainQueue.async(flags: .barrier) {
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: self._kSecAttrAccount,
                kSecValueData: data
            ]
            
            // Delete any existing token
            SecItemDelete(query as CFDictionary)
            
            // Add the new token
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Failed to save token: \(status)")
            }
        }
    }
    
    // Retrieves a token securely from the Keychain.
    func getToken() -> String? {
        var result: String?
        
        keychainQueue.sync {
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: _kSecAttrAccount,
                kSecReturnData: kCFBooleanTrue!,
                kSecMatchLimit: kSecMatchLimitOne
            ]
            
            var retrievedData: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &retrievedData)
            
            if status == errSecSuccess, let data = retrievedData as? Data {
                result = String(data: data, encoding: .utf8)
            } else {
                print("Failed to retrieve token: \(status)")
            }
        }
        
        return result
    }
    
    // Deletes a token securely from the Keychain.
    func deleteToken() {
        keychainQueue.async(flags: .barrier) {
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: self._kSecAttrAccount
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            if status != errSecSuccess && status != errSecItemNotFound {
                print("Failed to delete token: \(status)")
            }
        }
    }
}
