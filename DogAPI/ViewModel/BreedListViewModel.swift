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
    
    weak var service :NetworkService?
    private let persistentContainer: NSPersistentContainer
    //let storageManager: StorageManager

    var list : [String] = []
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private var isFetchInProgress = false
    
    init(service : NetworkService, persistentContainer: NSPersistentContainer) {
        self.service = service
        self.persistentContainer = persistentContainer
    }
    
    var currentCount: Int {
        return list.count
    }
    
    func feed(at index: Int) -> String {
        return list[index]
    }
    
    func fetchBreedList(_ completion: @escaping (Result<Bool, DataResponseError>) -> Void) {
        
        guard let _ = service else {
            completion(Result.failure(DataResponseError.custom("Missing service")))
            return
        }
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        let resource = Resource(url: NetworkService.shared.baseURL, path: "list/all")
        
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
            
            let taskContext = self?.persistentContainer.newBackgroundContext()
            taskContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext?.undoManager = nil
            
            _ = self?.syncBreed(jsonDictionary: jsonData["message"] as! [String : [String]], taskContext: taskContext! )
            
           // completion(Result.success(true))
            
//            switch result {
//
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self?.isFetchInProgress = false
//                    completion(Result.failure(error))
//                }
//            case .success(let response):
//
//                DispatchQueue.main.async {
//                    completion(Result.success(response.activities))
//                }
//            }
        })
    }
    
    func fetchBreedImages(breedType:String, _ completion: @escaping (Result<Bool, DataResponseError>) -> Void) {
        
        guard let _ = service else {
            completion(Result.failure(DataResponseError.custom("Missing service")))
            return
        }
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        let resource = Resource(url: NetworkService.shared.baseURL, path: "\(breedType)/images/random")
        
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
            
            let taskContext = self?.persistentContainer.newBackgroundContext()
            taskContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext?.undoManager = nil
            
            _ = self?.syncBreed(jsonDictionary: jsonData["message"] as! [String : [String]], taskContext: taskContext! )
            
            // completion(Result.success(true))
            
            //            switch result {
            //
            //            case .failure(let error):
            //                DispatchQueue.main.async {
            //                    self?.isFetchInProgress = false
            //                    completion(Result.failure(error))
            //                }
            //            case .success(let response):
            //
            //                DispatchQueue.main.async {
            //                    completion(Result.success(response.activities))
            //                }
            //            }
        })
    }
    
    private func syncBreed(jsonDictionary: [String : [String]], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            
            // Remove all charging data from persistent storage
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Breed")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try taskContext.execute(deleteRequest)
            } catch {
                let deleteError = error as NSError
                NSLog("\(deleteError), \(deleteError.localizedDescription)")
            }
            

            
//            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Breed")
//            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
//            batchDeleteRequest.resultType = .resultTypeObjectIDs
//
//            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
//            do {
//                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
//
//                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
//                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
//                                                        into: [self.persistentContainer.viewContext])
//                }
//            } catch {
//                print("Error: \(error)\nCould not batch delete existing records.")
//                return
//            }
            
            // Create new records.
            for (key, value) in jsonDictionary {
                
                guard let breed = NSEntityDescription.insertNewObject(forEntityName: "Breed", into: taskContext) as? Breed else {
                    print("Error: Failed to create a new Breed object!")
                    return
                }
                
                //                do {
                //                    try film.update(with: filmDictionary)
                //                } catch {
                //                    print("Error: \(error)\nThe quake object will be deleted.")
                //                    taskContext.delete(film)
                //                }
                
                breed.breedname = key
                
                var subBreeds : Set<SubBreed> = []
                
                for value in value {
                    let subbreed = NSEntityDescription.insertNewObject(forEntityName: "SubBreed", into: taskContext) as! SubBreed
                    subbreed.breedname = value
                    subBreeds.insert(subbreed)
                }
                
                breed.subbreed = subBreeds as NSSet
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
    
    
    private func syncBreedImage(jsonDictionary: [String : String], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            
            // Remove all charging data from persistent storage
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BreedImage")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try taskContext.execute(deleteRequest)
            } catch {
                let deleteError = error as NSError
                NSLog("\(deleteError), \(deleteError.localizedDescription)")
            }
            
            
            
            //            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Breed")
            //            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
            //            batchDeleteRequest.resultType = .resultTypeObjectIDs
            //
            //            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            //            do {
            //                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            //
            //                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
            //                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
            //                                                        into: [self.persistentContainer.viewContext])
            //                }
            //            } catch {
            //                print("Error: \(error)\nCould not batch delete existing records.")
            //                return
            //            }
            
            // Create new records.

                guard let breed = NSEntityDescription.insertNewObject(forEntityName: "BreedImage", into: taskContext) as? BreedImage else {
                    print("Error: Failed to create a new BreedImage object!")
                    return
                }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }

}
