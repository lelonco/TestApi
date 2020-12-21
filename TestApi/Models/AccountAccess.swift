//
//  AccountAccess.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//
import Foundation

class AccountAccess: Codable {
    
    var user: User? = nil
    var token: String? = nil
    var expierDate: Date? = nil
    var enteringMode: EnteringMode? = nil
//    var didEnteredWhenOffline = false
    
    convenience init(user: User?, token: String?, expierDate: Date?) {
        self.init()
        self.user = user
        self.token = token
        self.expierDate = expierDate
    }
}

enum EnteringMode:Int, Codable {
    case login
    case register
}

