//
//  TestApiRequest.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class TestApiRequest {
    var httpMethod: HttpMethod = .get
    var endPoint: String?
    var headerParameters: [String:Any] = ["Content-Type":"application/json"]
    var queryParam: [String:Any]?
    var httpBody: Data?
    init(endPoint: String) {
        self.endPoint = endPoint
    }
}
