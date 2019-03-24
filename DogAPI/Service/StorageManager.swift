//
//  StorageManager.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit
import CoreData

class StorageManager {
    
//    static let shared = StorageManager()
//    private init() {} // Prevent clients from creating another instance.
    
//    //MARK: Init with dependency
//    lazy var persistentContainer: NSPersistentContainer = {
//        //Use the default container for production environment
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("AppDelegate unavailable")
//        }
//        let container : NSPersistentContainer = appDelegate.persistentContainer
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        return container
//    }()

    let persistentContainer: NSPersistentContainer!
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    convenience init() {
        //Use the default container for production environment
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate unavailable")
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    //MARK:- Breed List
    
    func syncBreedList(jsonDictionary: [String : [String]], completion: @escaping (Bool) -> Void) {
        var successfull = false
        
            // Remove all charging data from persistent storage
           self.deleteBreedData()
        
            //Insert Breed data into Breed table
            for (key, value) in jsonDictionary {
                
                guard let model = NSEntityDescription.insertNewObject(forEntityName: "Breed", into: backgroundContext) as? Breed else {
                    //completion(successfull)
                    return
                }

                //Insert subbreed data into SubBreed table
                var subBreeds : Set<SubBreed> = []
                for value in value {
                    guard let subbreed = NSEntityDescription.insertNewObject(forEntityName: "SubBreed", into: backgroundContext) as? SubBreed else { return }
                    
                    subbreed.breedType = model
                    subbreed.subBreedname = value
                    subBreeds.insert(subbreed)
                }
                
                model.breedname = key
                model.subbreed = subBreeds as NSSet
            }
            
            //Save data in database
            save()
            successfull = true
            
            completion(successfull)
    }
    
    
    func fetchAllBreedList(sorted: Bool = true, isSearch:Bool = false, searchText: String = "") -> [Breed] {
        
       // let request: NSFetchRequest<Breed> = Breed.fetchRequest()
        let fetchRequest = NSFetchRequest<Breed>(entityName: "Breed")
        fetchRequest.relationshipKeyPathsForPrefetching = ["subbreed"]

        if isSearch {
            fetchRequest.predicate = NSPredicate(format: "breedname contains[c] %@", searchText)
        }
        
        if sorted {
            let nameSort = NSSortDescriptor(key: #keyPath(Breed.breedname), ascending: true)
            fetchRequest.sortDescriptors = [nameSort]
        }
        
        let results = try? self.persistentContainer.viewContext.fetch(fetchRequest)
        return results ?? [Breed]()
    }
    
   /*
    func updateBreedListIconImages(image: UIImage, breedType: String, imageUrl: String) {
            let request: NSFetchRequest<Breed> = Breed.fetchRequest()
            request.predicate = NSPredicate(format: "breedname == %@", breedType)
            
            do {
                let results = try persistentContainer.viewContext.fetch(request)
                if results.count > 0 {
                    guard let breed = results.first else {
                        return
                    }
                    guard let model = NSEntityDescription.insertNewObject(forEntityName: "BreedImage", into: backgroundContext) as? BreedImage else {
                        print("Error: Failed to create a new Breed object!")
                        return
                    }
                    
                    model.imageUrl = imageUrl
                    model.breedType = breed.breedname
                    model.subbreedType = breed.breedname
                    model.breedImageData = image.jpegData(compressionQuality:1.0)
                    breed.breedImage = model
                }
            }
            catch { return
            }
            
            //Save data in database
            save()
    }*/
    
    //MARK: - Breed Gallery methods
    
    func syncBreedImages(dataArray: [String], breed: String, subbreed: String, completion: @escaping (Bool) -> Void) {
        var successfull = false
        
            // Remove all charging data from persistent storage
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BreedImage")
            fetchRequest.predicate = NSPredicate(format: "breedType == %@", breed)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try backgroundContext.execute(deleteRequest)
            } catch {
                let deleteError = error as NSError
                NSLog("\(deleteError), \(deleteError.localizedDescription)")
                completion(successfull)
                return
            }
            
            // Create new records.
            for value in dataArray {
                
                guard let model = NSEntityDescription.insertNewObject(forEntityName: "BreedImage", into: backgroundContext) as? BreedImage else {
                    completion(successfull)
                    return
                }
                
                model.imageUrl = value
                model.breedType = breed
                model.subbreedType = subbreed
            }
            
            //Save data in database
            save()
            successfull = true
            
            completion(successfull)
    }
    
    
    func updateBreedImages(image: UIImage, breedType: String, imageUrl: String) {
        
            let request: NSFetchRequest<BreedImage> = BreedImage.fetchRequest()
            request.predicate = NSPredicate(format: "breedType == %@ && imageUrl == %@", breedType,imageUrl)
            
            do {
                let results = try self.persistentContainer.viewContext.fetch(request)
                if results.count > 0 {
                    guard let model = results.first else {
                        return
                    }
                   
                    model.breedImageData = image.jpegData(compressionQuality:1.0)
                    do {
                        try self.persistentContainer.viewContext.save()
                    }
                    catch {
                        
                    }
                }
            }
            catch { return
            }
    }
    
    func fetchBreedAllImages(breedType: String, subbreed: String) -> [BreedImage] {
        let request: NSFetchRequest<BreedImage> = BreedImage.fetchRequest()
        request.predicate = NSPredicate(format: "breedType == %@ && imageUrl contains[c]  %@", breedType,subbreed)

//        let nameSort = NSSortDescriptor(key: #keyPath(BreedImage.imageUrl), ascending: true)
//        request.sortDescriptors = [nameSort]
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [BreedImage]()
    }
    
    func save() {
        // Save all the changes just made and reset the taskContext to free the cache.
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Error: \(error)\nCould not save Core Data context.")
            }
        }
        
    }
    
    func deleteBreedData() {
        
        // Remove all charging data from persistent storage
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Breed")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.persistentContainer.viewContext.execute(deleteRequest)
        } catch {
            let deleteError = error as NSError
            NSLog("\(deleteError), \(deleteError.localizedDescription)")
        }
        
        // Remove all charging data from persistent storage
        let subbreedFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubBreed")
        let subbreedDeleteRequest = NSBatchDeleteRequest(fetchRequest: subbreedFetchRequest)
        
        do {
            try self.persistentContainer.viewContext.execute(subbreedDeleteRequest)
        } catch {
        }
        
        save()
    }
    
    
    func deleteBreedImagesData() {
        
        // Remove all charging data from persistent storage
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BreedImage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.persistentContainer.viewContext.execute(deleteRequest)
        } catch {
            let deleteError = error as NSError
            NSLog("\(deleteError), \(deleteError.localizedDescription)")
        }
        save()
    }

}
