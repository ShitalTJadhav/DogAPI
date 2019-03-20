//
//  Result.swift
//  ActivitiesApp
//
//  Created by Tushar  Jadhav on 2019-01-16.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
