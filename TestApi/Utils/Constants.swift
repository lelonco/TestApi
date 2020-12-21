//
//  Constants.swift
//  TestApi
//
//  Created by Yaroslav on 15.12.2020.
//

import Foundation

struct Constants {
    static let didRegistred = "didUserRegistred"
    static let didRegistredNotification = "didRegistredNotification"
    static let tokenChanged = "tokenDidChangedNotification"
    static let internetReacibilityCahnged = "internetReacibilityCahngedNotification"
    static let noInternetErorrs: [URLError.Code] = [.timedOut,.networkConnectionLost,.notConnectedToInternet]
}
