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
    
    enum CodingKeys:String, CodingKey {
        case id
        case title
        case dueBy
        case taskDescription
        case priority
    }
    
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
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id.value, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dueBy.value, forKey: .dueBy)
//        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(priorityString, forKey: .priority)
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try RealmOptional<Int>(container.decode(Int.self, forKey: .id))
        self.title = try container.decode(String.self, forKey: .title)
        self.dueBy = try RealmOptional<Int64>( container.decode(Int64.self, forKey: .dueBy))
        self.priorityString = try container.decode(String.self, forKey: .priority)
        self.taskDescription = try container.decode(String.self, forKey: .taskDescription)
    }
}
