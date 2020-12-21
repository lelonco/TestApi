//
//  ErorrMessage.swift
//  TestApi
//
//  Created by Yaroslav on 21.12.2020.
//

import Foundation

class ErrorMesasge: Codable {
    let message: String?
    let fields: ErrorFields?
    
    func getErrorMessage() -> String {
        (message ?? "") + "\n" + (fields?.description() ?? "")
    }
}

class ErrorFields : Codable {
    let email: [String]?
    let password: [String]?
    let title: [String]?
    let dueBy: [String]?
    let priority: [String]?
    
    
    func description() -> String {
        var description: String = ""
        Mirror(reflecting: self).children.forEach { (attr) in
            guard let arrayStrings = attr.value as? [String] else { return }
            description.append(arrayStrings.reduce("", { (first, second) in
                first + " " + second
            }))
        }
        return description
    }
}
