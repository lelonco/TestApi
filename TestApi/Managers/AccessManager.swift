//
//  AccessManager.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation


class AccessManager {
    
    static let shared = AccessManager()
    var accountAccess: AccountAccess? = nil
    
    var networkManager = NetworkManager.shared
    
    init() {
        guard let account = KeychainManager.getSecureAccountAccess() else { return }
        self.accountAccess = account
        _ = Timer.init(fireAt: account.expierDate!, interval: 0, target: self, selector: #selector(updateAccessToken), userInfo: nil, repeats: false)
    }
    
    @objc
    func updateAccessToken() {
        guard let user = accountAccess?.user else { return }
        let request = RequestBuilder.authorize(user: user)
        networkManager.makeRequest(request) { (response, object) in
            if let dict = (try! JSONSerialization.jsonObject(with: object as! Data, options: [])) as? [String:Any],
               let token = dict["token"] as? String {
                self.accountAccess?.token = token
                var dateComp = DateComponents()
                dateComp.hour = 24
                let calendar = Calendar.current
                let expierDate = calendar.date(byAdding: dateComp, to: Date())
                self.accountAccess?.expierDate = expierDate
                KeychainManager.updateTokensFrom(account: self.accountAccess!)
            }
        } failure: { (error) in
            assertionFailure(error.localizedDescription)
        }

    }
}
