//
//  KeychainHelper.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import Security
import Foundation

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrSynchronizable as String: true
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            Log.error("Keychain save failed", context: [
                "key": key,
                "status": status
            ])
        }
        return status == errSecSuccess
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrSynchronizable as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status != errSecSuccess {
            Log.error("Keychain load failed", context: [
                "key": key,
                "status": status
            ])
        }

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: true
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            Log.error("Keychain delete failed", context: [
                "key": key,
                "status": status
            ])
        }
        return status == errSecSuccess
    }
}
