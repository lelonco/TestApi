//
//  RequestBuilder.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation

enum SortingType:String {
    case asc
    case desc
}

class RequestBuilder {
    
    private static let encoder = JSONEncoder()
    private static let accessManager = AccessManager.shared
    
    static func registerNewUser(newUser: User) -> TestApiRequest {
        let request = TestApiRequest(endPoint: "users")
        request.httpMethod = .post
        do {
            request.httpBody = try encoder.encode(newUser)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        
        return request
    }
    
    static func getTasksRequest(page: Int, sortedBy:String, sortingType:SortingType) -> TestApiRequest {
        let request = TestApiRequest(endPoint: "tasks")
        request.httpMethod = .get
        request.queryParam = ["page": "\(page)",
                              "sort":(sortedBy + " " + sortingType.rawValue)]
        
        self.addAuthtoHeader(request: request)
        return request
    }
    
    static func uploadTaskRequest(with task: Task) -> TestApiRequest {
        let request = TestApiRequest(endPoint: "tasks")
        request.httpMethod = .post
        do {
            request.httpBody = try encoder.encode(task)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        self.addAuthtoHeader(request: request)
        return request
        
    }
    
    static func updateTaskRequest(with task: Task) -> TestApiRequest {
        guard let taskId = task.id.value else {
            assertionFailure("Cant get task id")
            return TestApiRequest(endPoint: "tasks")
        }
        let request = TestApiRequest(endPoint: "tasks/\(taskId)")
        request.httpMethod = .put
        do {
            request.httpBody = try encoder.encode(task)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        self.addAuthtoHeader(request: request)

        return request
    }
    
    static func deleteTaskRequest(with id: Int) -> TestApiRequest {
        let request = TestApiRequest(endPoint: "tasks/\(id)")
        request.httpMethod = .delete
        
        self.addAuthtoHeader(request: request)
        return request
    }

    static func authorize(user: User) -> TestApiRequest {
        let request = TestApiRequest(endPoint: "auth")
        request.httpMethod = .post
        do {
            request.httpBody = try encoder.encode(user)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return request
    }

    private static func addAuthtoHeader(request: TestApiRequest) {
        guard let token = Self.accessManager.accountAccess?.token else { return }
        request.headerParameters["Authorization"] = ("Bearer " + token)
    }
    
}
