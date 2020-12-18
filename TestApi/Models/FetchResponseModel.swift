//
//  FetchResponseModel.swift
//  TestApi
//
//  Created by Yaroslav on 18.12.2020.
//

import Foundation


struct FetchResponseModel: Decodable {
    let tasks: [Task]?
    let meta: FetchResponseMeta?
}

struct FetchResponseMeta: Decodable {
    let currentPage: Int
    let pageLimit: Int
    let taskCount: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current"
        case pageLimit = "limit"
        case taskCount = "count"
    }
}
