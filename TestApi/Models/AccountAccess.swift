//
//  AccountAccess.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//
import Foundation
import RealmSwift

@objcMembers
class AccountAccess: Object, Codable {
    
    dynamic var user: User? = nil
    dynamic var token: String? = nil
    dynamic var expierDate: Date? = nil
    
    convenience init(user: User?, token: String?, expierDate: Date?) {
        self.init()
        self.user = user
        self.token = token
        self.expierDate = expierDate
    }
}

