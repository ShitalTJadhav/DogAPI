//
//  NetworkService.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation

protocol NetworkingProtocol {
    func fetchData(resource: Resource, completion: @escaping(AnyObject?, DataResponseError?) -> Void)
}

/// Used to fetch data from network
class NetworkService : NetworkingProtocol {
    
    private let session: URLSession!
    
    lazy var baseURL: URL = {
        return URL(string: "https://dog.ceo/api/")!
    }()
    
    public static let shared = NetworkService()
    
    private init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchData(resource: Resource, completion: @escaping(AnyObject?,DataResponseError?) -> Void) {
        
        //Check internet connection
        if let reachability = Reachability(), !reachability.isReachable {
            completion(nil,DataResponseError.network)
            return
        }
        
        //Return if failed to create request
        guard let request = makeRequest(resource: resource) else {
            completion(nil,DataResponseError.custom("Error in making request"))
            return
        }
        
        let task = session.dataTask(with: request, completionHandler: { data, _, error in
            
            //Return error
            if let error = error {
                completion(nil, DataResponseError.custom(error.localizedDescription))
                return
            }
            
            //Data not receive
            guard let data = data else {
                completion(nil,DataResponseError.network)
                return
            }
            
            //Convert data to json object
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if ((jsonObject as? NSNull) != nil)  {
                    throw DataResponseError.decoding
                }
                completion(jsonObject as AnyObject, nil)
            } catch {
                completion(nil, DataResponseError.custom(error.localizedDescription))
            }
        })
        
        task.resume()
    }
    
    /// Convenient method to make request
    private func makeRequest(resource: Resource) -> URLRequest? {
        //let url = resource.path.map({ resource.url.appendingPathComponent($0) }) ?? resource.url
        let url = resource.url.appendingPathComponent(resource.path ?? "")
        
        guard var component = URLComponents(url: url , resolvingAgainstBaseURL: true) else {
            assertionFailure()
            return nil
        }
        
        component.queryItems = resource.parameters.map({
            return URLQueryItem(name: $0, value: $1)
        })
        
        guard let resolvedUrl = component.url else {
            assertionFailure()
            return nil
        }
        
        var request = URLRequest(url: resolvedUrl)
        request.httpMethod = resource.httpMethod
    
        return request
    }
}
