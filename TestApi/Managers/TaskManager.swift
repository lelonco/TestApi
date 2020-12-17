//
//  TaskManager.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation
import RealmSwift

class TaskManager {
    let networkManager: NetworkManager = NetworkManager.shared
    let databaseStorage = DatabaseManager.shared
    var notification: NotificationToken?
    var updatingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "UpdatingOperationQueue"
        
        return queue
    }()
    
    var pandingTasks: Results<Task>
    
    init() {
        self.pandingTasks = databaseStorage.objects(Task.self).filter("id == nil")
        notification = pandingTasks.observe{ (change) in
            switch change {
            
            case .initial(_):
                self.initialOperationsCreate()
            case .update(_, deletions: _, insertions: let insertions, modifications: _):
                insertions.forEach { (index) in
                    if let operation = self.createOperation(for: self.pandingTasks[index]) {
                        self.updatingQueue.addOperation(operation)
                    }
                }
            case .error(let error):
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    
    func initialOperationsCreate() {
        pandingTasks.forEach { (task) in
            if let operation = self.createOperation(for: task) {
                self.updatingQueue.addOperation(operation)
            }
        }
    }
    
    func createOperation(for task: Task) -> UpdateTaskInfoRemotlyOpeartion? {
        guard let request = self.createRequest(for: task) else {
            print("cant create opeartion for \(task.title)")
            return nil
            
        }
        print("uploadOperation created for \(task.title)")

        return UpdateTaskInfoRemotlyOpeartion(with: self.networkManager, request: request, task: task)
    }
    
    func createRequest(for task: Task) -> TestApiRequest? {
        if task.id.value == nil {
            return RequestBuilder.uploadTaskRequest(with: task)
        }
        return nil
    }
}


class UpdateTaskInfoRemotlyOpeartion: Operation {
    let networkManager: NetworkManager
    let request: TestApiRequest
    let task: Task
    let databaseStorage = DatabaseManager.shared
    init(with networkManager:NetworkManager, request: TestApiRequest, task: Task) {
        self.networkManager = networkManager
        self.request = request
        self.task = task
    }
    
    override func main() {
        guard !isCancelled else { return }
//        print("opeartion run for \(task.title)")

        networkManager.makeRequest(request) { (repsonse, object) in
            let decoder = JSONDecoder()
            
//            print(try! JSONSerialization.jsonObject(with: object as! Data, options: []))
            guard let task = try? decoder.decode(Task.self, from: object as! Data) else {
                assertionFailure("Cant parse task")
                return
                
            }
            DispatchQueue.main.sync {
                do {
                    try self.databaseStorage.write {
                        self.task.id = task.id
                    }
                } catch {
                    assertionFailure(error.localizedDescription)
                }
                
            }
        } failure: { (error) in
            assertionFailure(error.localizedDescription)
        }

    }
    
    
}
