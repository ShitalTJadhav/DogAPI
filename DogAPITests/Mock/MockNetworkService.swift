//
//  MockNetworkService.swift
//  DogAPITests
//
//  Created by Tushar  Jadhav on 2019-03-22.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation
@testable import DogAPI

final class MockNetworkService: NetworkingProtocol {
    
    var fileName: String?
    
    func fetchData(resource: Resource, completion: @escaping(AnyObject?,DataResponseError?) -> Void) {
        let bundle = Bundle(for: MockNetworkService.self)
        
        guard let url = bundle.url(forResource: self.fileName, withExtension: "json") else {
            completion(nil, DataResponseError.custom("json file not found"))
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            //Convert data to json object
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if ((jsonObject as? NSNull) == nil)  {
                    throw DataResponseError.decoding
                }
                
                completion(jsonObject as AnyObject,nil)
            } catch {
                completion(nil, DataResponseError.decoding)
            }
        } catch  {
            completion(nil, DataResponseError.custom("Data is nil"))
        }

    }
}
