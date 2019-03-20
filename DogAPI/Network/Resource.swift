//
//  Resource.swift
//  ActivitiesApp
//
//  Created by Tushar  Jadhav on 2019-03-03.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation

// A network resource, identified by url and parameters
struct Resource {
    let url: URL
    let path: String?
    let httpMethod: String
    let parameters: [String: String]
    
    init(url: URL, path: String? = nil, httpMethod: String = "GET", parameters: [String: String] = [:]) {
        self.url = url
        self.path = path
        self.httpMethod = httpMethod
        self.parameters = parameters
    }
}
