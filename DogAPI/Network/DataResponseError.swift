//
//  DataResponseError.swift
//  ActivitiesApp
//
//  Created by Tushar  Jadhav on 2019-01-16.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation

enum DataResponseError: Error {
    case network
    case decoding
    case custom(String)

    var reason: String {
        switch self {
        case .network:
            return "An error occurred while fetching data"
        case .decoding:
            return "An error occurred while decoding json data"
        case .custom:
            return ""
        }
       
    }
}

