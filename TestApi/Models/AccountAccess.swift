//
//  AccountAccess.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//
import Foundation

struct AccountAccess: Codable {
    
    let user: User?
    var token: String?
    var expierDate: Date?
    
}
