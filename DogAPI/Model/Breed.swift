//
//  Breed.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation

struct Breed: Decodable {
    
    let status: String
    
    //List of all breeds
    let message: [String]
}
