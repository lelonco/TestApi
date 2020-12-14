//
//  KeychainManager.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//


import Foundation
import Security


class KeychainManager: NSObject {    
    private static let key = "TestApiAAccountAccess"
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    public static func save(account: AccountAccess) {
        do {
            let data = try encoder.encode(account)
            self.saveSecureInfo(for: data)
        } catch {
            assertionFailure("Cant save account access to keychain")
        }
    }
    
    public static func updateTokensFrom(account : AccountAccess) {
        do {
            let data = try encoder.encode(account)
            updateSecureInfo(for: data)
        } catch {
            assertionFailure("Can't encode account to data")
        }
    }
    
    public static func saveSecureInfo(for data: Data?) {
        
        guard let valueData = data else {
            assertionFailure("Can't get data")
            return
        }
        
        let keychainItem = [kSecClass: kSecClassGenericPassword,
                            kSecReturnData: true,
                            kSecReturnAttributes: true,
                            kSecAttrAccount: self.key,
                            kSecValueData: valueData] as CFDictionary
        
        _ = SecItemAdd(keychainItem, nil)
    }
    
    public static func getSecureAccountAccess() -> AccountAccess? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecReturnAttributes: true,
            kSecMatchLimit: 1,
        ] as CFDictionary
        
        var result: AnyObject?
        _ = SecItemCopyMatching(query, &result)
        
        guard let resultDict = result as? NSDictionary else {
            return nil
        }
        
        guard let secureData = resultDict[kSecValueData] as? Data  else { return nil }
        var secureInfo: AccountAccess? = nil
        do {
            secureInfo = try decoder.decode(AccountAccess.self, from: secureData)
        } catch {
            assertionFailure("Can't decode data to `AccountAccess")
        }
        return secureInfo
    }
    
    
    public static func updateSecureInfo(for account: Data) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        let tokenData = account
        let updateFields = [
            kSecValueData: tokenData
        ] as CFDictionary
        
        _ = SecItemUpdate(query, updateFields)
    }
    
    public static func removeSecureInfo() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecReturnAttributes: true,
        ] as CFDictionary
        
        _ = SecItemDelete(query)
        
    }
}


