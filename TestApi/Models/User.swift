//
//  User.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation

class User: Codable {
    dynamic var email: String? = nil
    dynamic var password: String? = nil

    convenience init(email: String, password: String) {
        self.init()
        self.email = email
        self.password = password
    }

}
