//
//  AccessManager.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation
import UIKit

class AccessManager {
    
    static let shared = AccessManager()
    var accountAccess: AccountAccess? = nil
    
    var networkManager = NetworkManager.shared
    
    init() {
        let didRegistred = UserDefaults.standard.bool(forKey: Constants.didRegistred)
        guard didRegistred,
              let account = KeychainManager.getSecureAccountAccess() else {
            KeychainManager.removeSecureInfo()
            return
        }
        self.accountAccess = account
        if account.token == nil {
            switch account.enteringMode {
            case .login:
                self.login()
            case .register:
                self.register()
            case .none:
                assertionFailure("unexpected accountAccess enteringMode value")
            }
        } else {
            updateAccessTokenIfNeeded()
        }
    }
    
    func updateAccessTokenIfNeeded() {
        guard let expierDate = accountAccess?.expierDate else {
            assertionFailure("Have no account access in offline mode probably")
            return
        }
        if expierDate <= Date() {
            updateAccessToken()
        } else {
            _ = Timer.init(fireAt: expierDate, interval: 0, target: self, selector: #selector(updateAccessToken), userInfo: nil, repeats: false)
            TaskManager.shared.startExecute()
        }
    }
    
    @objc
    func updateAccessToken() {
        TaskManager.shared.cleanQueue()
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
                TaskManager.shared.startExecute()
                self.updateAccessTokenIfNeeded()
            }
        } failure: { (error) in
            if !Reachability.shared.isConnected {
                
            }
            assertionFailure(error.localizedDescription)
        }
    }
    
    func register() {
        guard let user = self.accountAccess?.user else { return }
        guard let frontViewController = UIApplication.topViewController() as? BaseViewController else { return }

        let request = RequestBuilder.registerNewUser(newUser: user)
        networkManager.makeRequest(request) { (response, responeObject) in
            switch (response as? HTTPURLResponse)?.statusCode {
            case 201:
                if let dict = (try! JSONSerialization.jsonObject(with: responeObject as! Data, options: [])) as? [String:Any],
                   let token = dict["token"] as? String {
                    self.saveAccessToken(with: token)
                }
            case 404:
                frontViewController.presentAlert(title: "Error", message: "Something went wrong 404")
            default:
                let decoder = JSONDecoder()
                let errorMessage = try! decoder.decode(ErrorMesasge.self, from: responeObject as! Data)
                DispatchQueue.main.async {
                    frontViewController.presentAlert(title: errorMessage.message ?? "", message: errorMessage.fields?.description() ?? "")
                }
                UserDefaults.standard.setValue(false, forKey: Constants.didRegistred)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.didRegistredNotification), object: nil)
            }
        } failure: { (error) in
            if !Reachability.shared.isConnected {
                self.saveAccessToken(with: nil)
            }
            assertionFailure(error.localizedDescription)
        }
    }
    
    func login() {
        guard let user = self.accountAccess?.user else { return }
        guard let frontViewController = UIApplication.topViewController() as? BaseViewController else { return }

        let request = RequestBuilder.authorize(user: user)
        networkManager.makeRequest(request) { (response, responeObject) in
            switch (response as? HTTPURLResponse)?.statusCode {
            case 200:
                if let dict = (try! JSONSerialization.jsonObject(with: responeObject as! Data, options: [])) as? [String:Any],
                   let token = dict["token"] as? String {
                    self.saveAccessToken(with: token)
                }
            case 403,422:
                let decoder = JSONDecoder()
                let errorMessage = try! decoder.decode(ErrorMesasge.self, from: responeObject as! Data)
                print(errorMessage.getErrorMessage())
                DispatchQueue.main.async {
                    frontViewController.presentAlert(title: errorMessage.message ?? "", message: errorMessage.fields?.description() ?? "") {
                        UserDefaults.standard.setValue(false, forKey: Constants.didRegistred)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.didRegistredNotification), object: nil)
                    }
                }

            default:
                assertionFailure("Something went wrong status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            }
        } failure: { (error) in
            if !Reachability.shared.isConnected {
                self.saveAccessToken(with: nil)
            }
//            assertionFailure(error.localizedDescription)
        }
    }
    
    func saveAccessToken(with token: String?) {
        
        self.accountAccess?.token = token
        var dateComp = DateComponents()
        dateComp.hour = 24
        let calendar = Calendar.current
        let expierDate = calendar.date(byAdding: dateComp, to: Date())
        self.accountAccess?.expierDate = expierDate
        KeychainManager.updateTokensFrom(account: self.accountAccess!)
        TaskManager.shared.startExecute()
        self.updateAccessTokenIfNeeded()
    }
}
