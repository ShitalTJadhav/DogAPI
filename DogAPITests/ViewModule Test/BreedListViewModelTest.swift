//
//  BreedListViewModelTest.swift
//  DogAPITests
//
//  Created by Tushar  Jadhav on 2019-03-22.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import XCTest
import CoreData
@testable import DogAPI

class BreedListViewModelTest: XCTestCase {
    
    private var viewModel : BreedListViewModel!
    private var mockNetworkService: MockNetworkService!

    var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DogAPI", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("In memory coordinator creation failed \(error)")
            }
        }
        return container
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockNetworkService = MockNetworkService()
        viewModel = BreedListViewModel(service: mockNetworkService, storageManager: StorageManager(container: mockPersistantContainer))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockNetworkService = nil
        viewModel = nil
    }
    
    // MARK: - UICollectionView Datasource methods

    func testCheckEmpty() {
        if let _ = self.viewModel {
            self.viewModel.fetchBreed_fromStorage()
            XCTAssertEqual(self.viewModel.currentCount, 0)
        }
        else {
            XCTFail()
        }
    }
    
    func testFetchBreedList() {
        
        let expectation = self.expectation(description: #function)
        self.mockNetworkService.fileName = "BreedList"
        
        self.viewModel.fetchBreedList_fromServer{ result in
            switch result {
            case .failure(let error):
                XCTAssert(false, "Service not be able to fetch breed list - \(error.reason)")
            case .success(let sucess):
                XCTAssertTrue(sucess)
                
                //Check data is save into db
                self.viewModel.fetchBreed_fromStorage()
                XCTAssertEqual(self.viewModel.currentCount, 50)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testSearch_BreedList() {
        
        // expected completion to succeed
        viewModel.searchsBreed_fromStorage(text: "hound", completionHandler:{ result in
            
            if result {
                XCTAssertEqual(self.viewModel.searchTotalCount, 1, "Page count is 1")
            }
        })
    }
    
//    func testInsert() {
//        guard let _ = self.viewModel else {
//            XCTFail()
//            return
//        }
//
//        self.viewModel.fetchBreed_fromStorage()
//        XCTAssertEqual(self.viewModel.currentCount, 0)
//
//    }
    
    
}
