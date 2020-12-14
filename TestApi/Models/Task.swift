//
//  Task.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation

enum TaskPriority:String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct Task: Codable {
    let id: Int
    let title: String?
    let dueBy: Int64?
    let priority: TaskPriority?
    let description: String?
}
