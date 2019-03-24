//
//  BreedListViewModel.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import Foundation
import CoreData

class BreedListViewModel {
    
    var service :NetworkingProtocol?
    
    let storageManager: StorageManager
    private var isFetchInProgress = false
    var filteredList: [Breed] = []
        
    lazy var list: [Breed] = {
        return storageManager.fetchAllBreedList()
    }()
    
    init(service : NetworkingProtocol, storageManager: StorageManager = StorageManager()) {
        self.service = service
        self.storageManager = storageManager
    }
    
    var currentCount: Int {
        return list.count
    }
    
    var searchTotalCount: Int {
        return filteredList.count
    }
    
    func feed(at index: Int) -> Breed {
        return list[index]
    }
    
    // MARK: - API Call Methods

    func fetchBreedList_fromServer(_ completion: @escaping (Result<Bool, DataResponseError>) -> Void) {
        
        guard let _ = service else {
            completion(Result.failure(DataResponseError.custom("Missing service")))
            return
        }
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        let resource = Resource(url: NetworkService.shared.baseURL, path: "breeds/list/all")
        
        _ = service?.fetchData(resource: resource, completion: {[weak self] (jsonData, error) in
            
            self?.isFetchInProgress = false
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            guard let jsonData = jsonData else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }
            
            guard let data = jsonData["message"] as? [String : [String]] else {
                completion(Result.failure(DataResponseError.custom("Unable to get data list")))
                return
            }
            
            self?.storageManager.syncBreedList(jsonDictionary: data, completion: {[weak self] sucess in
                if sucess == true {
                    //Fetch data from coredata
                    self?.fetchBreed_fromStorage()
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(DataResponseError.custom("Unable to save data")))
                }
            })
        })
    }
    
    func fetchBreed_fromStorage() {
        if list.count == 0 {
            self.list = self.storageManager.fetchAllBreedList()
        }
    }

    func searchsBreed_fromStorage(text: String, completionHandler: (_ result: Bool) -> Void) {
        self.filteredList = self.storageManager.fetchAllBreedList(sorted: true, isSearch: true, searchText: text)
        completionHandler(true)
    }
    

    
    //Clear search result
    func clearSearchResult() {
        
        if searchTotalCount != 0 {
            self.filteredList.removeAll()
        }
    }

}
