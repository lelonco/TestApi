//
//  DeleteRemotelyJobRecord.swift
//  TestApi
//
//  Created by Yaroslav on 19.12.2020.
//

import Foundation
import RealmSwift
@objcMembers
class DeleteRemotelyJobRecord: Object {
    dynamic var taskId: Int = 0
    
    convenience init(taskId: Int) {
        self.init()
        self.taskId = taskId
    }
}
