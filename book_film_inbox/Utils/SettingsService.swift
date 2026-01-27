//
//  SettingsService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

class SettingsService {
    
    static let shared = SettingsService()
    private let keychain = KeychainHelper.shared
    
    func getToken(for source: String) -> String? {
        keychain.load(key: "token_\(source)")
    }
    
    func saveToken(for source: String, token: String) {
        _ = keychain.save(key: "token_\(source)", value: token)
    }
    
    func removeToken(for source: String) {
        _ = keychain.delete(key: "token_\(source)")
    }
    
}
