//
//  TaskManager.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation
import RealmSwift

class TaskManager {
    var didStarted = false
    static let shared = TaskManager()
    private var isFetching = false
    private let networkManager: NetworkManager = NetworkManager.shared
    private let databaseStorage = DatabaseManager.shared

     var updatingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "UpdatingOperationQueue"
        
        return queue
    }()
    
    private var uploadPandingTasks: Results<Task>!
    private var pandingDeletionJobs: Results<DeleteRemotelyJobRecord>!
    private var pandingUpdateTasks: Results<Task>!
    
    private var notificationUpload: NotificationToken?
    private var notificationDelete: NotificationToken?
    private var notificationUpdate: NotificationToken?

    
    init() {

    }
    
    func startExecute() {
        guard !didStarted else { return }
        DispatchQueue.main.async {
            self.uploadPandingTasks = self.databaseStorage.objects(Task.self).filter("id == nil")
            self.pandingDeletionJobs = self.databaseStorage.objects(DeleteRemotelyJobRecord.self)
            self.pandingUpdateTasks = self.databaseStorage.objects(Task.self).filter("wasEdited = true && id != nil")
            
            self.notificationUpload = self.uploadPandingTasks.observe{ (change) in
                self.uploadTasksToRemote(with: change)
            }
            self.notificationDelete = self.pandingDeletionJobs.observe({ (change) in
                self.deleteTasksFromRemote(with: change)
            })
            self.notificationUpdate = self.pandingUpdateTasks.observe({ (change) in
                self.updateTasksOnRemote(with: change)
            })
            self.didStarted = true
            self.updatingQueue.isSuspended = false
        }

    }
    func cleanQueue() {
        self.updatingQueue.isSuspended = true
        self.updatingQueue.cancelAllOperations()
        self.didStarted = false
    }
    //MARK: - Download
    
    func fetchRemoteCaller(sortedBy: String, sortingType:SortingType, complition:@escaping () -> ()) {
        guard !isFetching else { return }
        self.fetchRemote(sortedBy: sortedBy, sortingType:sortingType, page: 1, complition:complition)
    }
    
    private func fetchRemote(sortedBy: String, sortingType:SortingType, page:Int = 1, complition:@escaping () -> ()) {
        let request = RequestBuilder.getTasksRequest(page: page, sortedBy: sortedBy, sortingType: sortingType)
        self.isFetching = true
        self.networkManager.makeRequest(request) { [weak self] (response, object) in
            let jsonDecoder = JSONDecoder()
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let responseObject = try? jsonDecoder.decode(FetchResponseModel.self, from: object as! Data),
                  let self = self else { return }
            let taskCount = responseObject.meta?.taskCount
            let taskFetched = ((responseObject.meta!.currentPage)  * responseObject.meta!.pageLimit)
            let taskRemaining = taskCount! - taskFetched
            
            self.compareTasks(with: responseObject.tasks ?? [])
            
            if taskRemaining > 0 {
                self.fetchRemote(sortedBy: sortedBy,
                                 sortingType: sortingType,
                                 page:responseObject.meta!.currentPage + 1,
                                 complition: complition)
            } else {
                self.isFetching = false
                DispatchQueue.main.async {
                    complition()
                }
            }
        } failure: { (error) in
            assertionFailure(error.localizedDescription)
            complition()
        }
        
    }
    
    func compareTasks(with tasks: [Task]) {
        autoreleasepool {
            let realm = try! Realm()
            tasks.forEach({ (task) in
                let taskId = task.id.value
                if let storredTask = realm.objects(Task.self).filter("id == \(taskId ?? 0)").first {
                    try? realm.write {
                        task.taskUUID = storredTask.taskUUID
                        task.taskDescription = storredTask.taskDescription
                        
                        realm.add(task, update: .modified)
                    }
                } else {
                    try? realm.write {
                        realm.add(task)
                        
                    }
                }
            })
        }
    }
    
    //MARK: - Delete
    
    private func deleteTasksFromRemote(with change: RealmCollectionChange<Results<DeleteRemotelyJobRecord>>) {
        switch change {
        
        case .initial(_):
            self.initialDeleteOperationsCreate()
        case .update(_, deletions: _, insertions: let insertions, modifications: _):
            insertions.forEach { (index) in
                self.updatingQueue.addOperation(self.createDeleteOperation(for: self.pandingDeletionJobs[index]))
            }
        case .error(let error):
            assertionFailure(error.localizedDescription)
        }
    }
    
    func initialDeleteOperationsCreate() {
        self.pandingDeletionJobs.forEach { (record) in
            self.updatingQueue.addOperation(self.createDeleteOperation(for: record))
        }
    }
    
    func createDeleteOperation(for jobRecord: DeleteRemotelyJobRecord) -> UpdateTaskInfoRemotlyOpereation {
        let request = RequestBuilder.deleteTaskRequest(with: jobRecord.taskId)
        return  UpdateTaskInfoRemotlyOpereation(with: self.networkManager, request: request) { [weak self] in
            DispatchQueue.main.async {
                do {
                    try self?.databaseStorage.write {
                        self?.databaseStorage.delete(jobRecord)
                    }
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Upload
    
    private func uploadTasksToRemote(with change: RealmCollectionChange<Results<Task>>) {
        switch change {
        
        case .initial(_):
            self.initialUploadOperationsCreate()
        case .update(_, deletions: _, insertions: let insertions, modifications: _):
            insertions.forEach { (index) in
                if let operation = self.createOperation(for: self.uploadPandingTasks[index]) {
                    self.updatingQueue.addOperation(operation)
                }
            }
        case .error(let error):
            assertionFailure(error.localizedDescription)
        }
    }
    
    func initialUploadOperationsCreate() {
        uploadPandingTasks.forEach { (task) in
            if let operation = self.createOperation(for: task) {
                self.updatingQueue.addOperation(operation)
            }
        }
    }
    
    func createOperation(for task: Task) -> AddTaskInfoRemotlyOpeartion? {
        guard let request = self.createRequest(for: task) else {
            return nil
        }
        return AddTaskInfoRemotlyOpeartion(with: self.networkManager, request: request, task: task)
    }
    
    func createRequest(for task: Task) -> TestApiRequest? {
        if task.id.value == nil {
            return RequestBuilder.uploadTaskRequest(with: task)
        }
        if task.wasEdited {
            return RequestBuilder.updateTaskRequest(with: task)
        }
        return nil
    }
    
    //MARK: - Update

    private func updateTasksOnRemote(with change: RealmCollectionChange<Results<Task>>) {
        switch change {
        case .initial(_):
            self.initialUpdateOperationsCreate()
        case .update(_, deletions: _, insertions: let insertions, modifications: _):
            insertions.forEach { (index) in
                if let operation = self.createUpdateOperation(for: self.pandingUpdateTasks[index]) {
                    self.updatingQueue.addOperation(operation)
                }
            }
        case .error(let error):
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func initialUpdateOperationsCreate() {
        uploadPandingTasks.forEach { (task) in
            if let operation = self.createUpdateOperation(for: task) {
                self.updatingQueue.addOperation(operation)
            }
        }
    }
    
    private func createUpdateOperation(for task: Task) -> UpdateTaskInfoRemotlyOpereation? {
        guard let request = self.createRequest(for: task) else {
            return nil
        }
        return UpdateTaskInfoRemotlyOpereation(with: self.networkManager, request: request) { [weak self] in
            DispatchQueue.main.async {
                do {
                    try self?.databaseStorage.write {
                        task.wasEdited = false
                    }
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }
}

//MARK: - Operations

class UpdateTaskInfoRemotlyOpereation: Operation {
    
    let networkManager: NetworkManager
    let request: TestApiRequest
    let requestSuccess: (() -> ())?
    init(with networkManager:NetworkManager, request: TestApiRequest, requestSuccess: (() -> ())? = nil) {
        self.networkManager = networkManager
        self.request = request
        self.requestSuccess = requestSuccess
    }
    
    override func main() {
        guard !isCancelled else { return }

        self.networkManager.makeRequest(request) { (response, data) in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            
            switch statusCode {
            case 200...202:
                self.requestSuccess?()
            case 400...499:
                if ((response as? HTTPURLResponse)?.allHeaderFields["Content-type"] as? String)?.contains("json") ?? false {
                    print(try? JSONSerialization.jsonObject(with: data as! Data, options: []))
                }
                assertionFailure("Something went wrong")
            default:
                // probably internet connetion
            break
            }
        } failure: { (error) in

//            assertionFailure(error.localizedDescription)
        }

    }
}

class AddTaskInfoRemotlyOpeartion: Operation {
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

        networkManager.makeRequest(request) { (repsonse, object) in
            let decoder = JSONDecoder()
            
            guard let task = try? decoder.decode(Task.self, from: object as! Data) else {
                assertionFailure("Cant parse task")
                return
                
            }
            DispatchQueue.main.async {
                do {
                    try self.databaseStorage.write {
                        self.task.id = task.id
                        task.taskDescription = self.task.taskDescription
                        task.taskUUID = self.task.taskUUID
                        self.databaseStorage.add(task, update: .modified)
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
