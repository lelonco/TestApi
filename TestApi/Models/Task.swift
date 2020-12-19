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
    case normal = "Normal"
    case high = "High"
}
@objcMembers
class Task: Object, Codable {
    
    enum CodingKeys:String, CodingKey {
        case task
        case id 
        case title
        case dueBy
        case taskDescription
        case priority
    }
    dynamic var taskUUID = UUID().uuidString
    dynamic var id = RealmOptional<Int>()
    dynamic var title: String? = nil
    dynamic var dueBy = RealmOptional<Int64>()
    dynamic var priorityString: String?
    dynamic var wasEdited: Bool = false
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
        self.taskDescription = taskDescription
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(dueBy.value, forKey: .dueBy)
        try container.encode(priorityString, forKey: .priority)
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let task = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .task) {
            self.id = try RealmOptional<Int>(task.decode(Int.self, forKey: .id))
            self.title = try task.decode(String.self, forKey: .title)
            self.dueBy = try RealmOptional<Int64>( task.decode(Int64.self, forKey: .dueBy))
            self.priorityString = try task.decode(String.self, forKey: .priority)
            self.taskDescription = try? task.decode(String.self, forKey: .taskDescription)
        } else {
            self.id = try RealmOptional<Int>(container.decode(Int.self, forKey: .id))
            self.title = try container.decode(String.self, forKey: .title)
            self.dueBy = try RealmOptional<Int64>( container.decode(Int64.self, forKey: .dueBy))
            self.priorityString = try container.decode(String.self, forKey: .priority)
            self.taskDescription = try? container.decode(String.self, forKey: .taskDescription)
        }
    }
    override class func primaryKey() -> String? {
        return "taskUUID"
    }
}
