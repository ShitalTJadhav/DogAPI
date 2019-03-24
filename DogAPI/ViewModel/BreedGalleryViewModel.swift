//
//  BreedGalleryViewModel.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-21.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation
import CoreData

class BreedGalleryViewModel {
    
    var service :NetworkingProtocol?
    let storageManager: StorageManager
    
    var breedType : String!
    var subBreedType : String!
    
    init(service : NetworkingProtocol = NetworkService.shared, storageManager: StorageManager = StorageManager(), breed: String, subbreed: String) {
        self.service = service
        self.storageManager = storageManager
        self.breedType = breed
        self.subBreedType = subbreed
    }
    
    lazy var list: [BreedImage] = {
         self.storageManager.fetchBreedAllImages(breedType: breedType, subbreed: breedType)
    }()
    
    var currentCount: Int {
        return list.count
    }
    
    func feed(at index: Int) -> BreedImage {
        return list[index]
    }
    
    func fetchBreedImages_fromServer(_ completion: @escaping (Result<Bool, DataResponseError>) -> Void) {
        
        guard let _ = service else {
            completion(Result.failure(DataResponseError.custom("Missing service")))
            return
        }
        
        let resource = Resource(url: NetworkService.shared.baseURL, path: "breed/\(self.breedType!)/images")
        
        _ = service?.fetchData(resource: resource, completion: {[weak self] (jsonData, error) in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            guard let jsonData = jsonData else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            
            guard let data = jsonData["message"] as? [String] else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            
            self?.storageManager.syncBreedImages(dataArray: data, breed: self?.breedType ?? "", subbreed: self?.subBreedType ?? "", completion: {[weak self] sucess in
                if sucess == true {
                    //Fetch data from coredata
                    self?.fetchBreedImage_fromStorage()
                    
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(DataResponseError.custom("Unable to save data")))
                }
            })
        })
    }
    
    func fetchBreedImage_fromStorage() {
        self.list = self.storageManager.fetchBreedAllImages(breedType: breedType, subbreed: subBreedType)
    }
}
