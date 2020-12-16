//
//  Task.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation
import RealmSwift

enum TaskPriority:String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}
@objcMembers
class Task: Object, Codable {
    dynamic var id: Int? = nil
    dynamic var title: String? = nil
    dynamic var dueBy: Int64? = nil
    private dynamic var priorityString: String? = nil
    dynamic var priority: TaskPriority? {
        get {
            guard let string = priorityString else { return nil }
            return TaskPriority(rawValue: string)
        }
        set {  priorityString = newValue?.rawValue }
    }
    dynamic var taskDescription: String?

    convenience init(id: Int, title: String?, dueBy: Int64?, priority: TaskPriority?, taskDescription: String?) {
        self.init()
        self.id = id
        self.title = title
        self.dueBy = dueBy
        self.priorityString = priority?.rawValue
//        self.priority = priority
        self.taskDescription = taskDescription
    }
}
