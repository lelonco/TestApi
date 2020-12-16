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
    dynamic var id = RealmOptional<Int>()
    dynamic var title: String? = nil
    dynamic var dueBy = RealmOptional<Int64>()
    dynamic var priorityString: String?
    var priority: TaskPriority? {
        get {
            guard let string = priorityString else { return nil }
            return TaskPriority(rawValue: string)
        }
        set {  priorityString = newValue?.rawValue }
    }
    dynamic var taskDescription: String?

    convenience init(id: Int?, title: String?, dueBy: Int64?, priority: TaskPriority?, taskDescription: String?) {
        self.init()
        self.id = RealmOptional(id)
        self.title = title
        self.dueBy = RealmOptional(dueBy)
        self.priorityString = priority?.rawValue
//        self.priority = priority
        self.taskDescription = taskDescription
    }
}
