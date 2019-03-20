//
//  BreedListViewController.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit
import CoreData

class BreedListViewController: UIViewController {

    @IBOutlet var listView: UICollectionView!
    let reuseIdentifier = "BreedListIdentifier"
    
    var viewModel : BreedListViewModel!
    private var networkService: NetworkService!

    
    lazy var fetchedResultsController: NSFetchedResultsController<Breed> = {
        let fetchRequest = NSFetchRequest<Breed>(entityName:"Breed")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "breedname", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: viewModel.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()

    
//    lazy var fetchedResultsController: NSFetchedResultsController<Breed> = {
//
//
//        let fetchRequest: NSFetchRequest<Breed> = Breed.fetchRequest()
//        let countrySort = NSSortDescriptor(key: #keyPath(Breed.breedname), ascending: true)
//        fetchRequest.sortDescriptors = [countrySort]
//
//        let fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: viewModel.persistentContainer.viewContext,
//            sectionNameKeyPath: #keyPath(Breed.breedname),
//            cacheName: nil)
//
//        fetchedResultsController.delegate = self
//
//        return fetchedResultsController
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Breed List"
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate unavailable")
        }
        
        self.viewModel = BreedListViewModel(service: NetworkService.shared, persistentContainer: appDelegate.persistentContainer)
        
        //Set list view
        setUpCollectionView()
        
        fetchBreedList()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Setup / Private methods

    fileprivate func setUpCollectionView() {
        
       // listView.isHidden = true
        listView.dataSource = self
        listView.accessibilityIdentifier = "BreedListViewIdentifier"
    }
    
    fileprivate func fetchBreedList() {
        
        viewModel.fetchBreedList {[unowned self] result in
            switch result {
            case .failure:
                print("Error in breed list fetching")
            case .success:
                print("Fetch breed list sucessfully")
            }
        }
       
    }
}

extension BreedListViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BreedListViewCell
        //cell.backgroundColor = .red
        // Configure the cell
//        let model = viewModel.list[indexPath.row] as! Breed
         let model = fetchedResultsController.object(at: indexPath)
        cell.breedNameLabel.text = model.breedname
        print("subbreed Count: ",model.subbreed?.count)
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension BreedListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        listView.reloadData()
    }
}
