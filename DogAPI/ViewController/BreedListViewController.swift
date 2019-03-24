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
    @IBOutlet var searchBar: UISearchBar!

    let reuseIdentifier = "BreedListIdentifier"
    
    var viewModel : BreedListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Breed List"
        
        self.viewModel = BreedListViewModel(service: NetworkService.shared)
        
        //Set up navigation
        setUpNavigation()
        
        //Set list view
        setUpCollectionView()

        //Set Search bar
        setUpSearchBar()
        
        fetchBreedList()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "BreedDetailViewController" {
            if let detailViewController = segue.destination as? BreedPhotoGalleryViewController {
                let cell = sender as! BreedListViewCell
                detailViewController.breed = cell.model
            }
        }
    }
    

    // MARK: - Setup / Private methods

    fileprivate func setUpNavigation() {
        //Application navigation color
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = ColorPalette.appMainColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    fileprivate func setUpCollectionView() {
        
       // listView.isHidden = true
        listView.dataSource = self
        listView.delegate = self
        listView.accessibilityIdentifier = "BreedListViewIdentifier"
    }
    
    fileprivate func setUpSearchBar() {
        //Set up search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search breed by name"
        searchBar.accessibilityIdentifier = "Breed_SearchBar"
    }
    
    fileprivate func fetchBreedList() {
        
        viewModel.fetchBreedList_fromServer{[unowned self] result in
            switch result {
            case .failure(let error):
                self.showAlertWithMessage(message: error.reason)
            case .success:
                DispatchQueue.main.async {
                    self.listView?.reloadData()
                }
            }
        }
    }
    
    
    fileprivate func isSearching() -> Bool {
        let searchBarIsEmpty = searchBar.text?.isEmpty ?? true
        return !searchBarIsEmpty
    }
    
}

// MARK: - UICollectionView Datasource methods

extension BreedListViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching() {
            return viewModel.searchTotalCount
        }
        else {
            return viewModel.currentCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BreedListViewCell
        // Configure the cell
        cell.tag = indexPath.row
        if isSearching() {
            cell.model = viewModel.filteredList[indexPath.row]
        }
        else {
            cell.model = viewModel.list[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

       // let animation = AnimationFactory.makeFade(duration: 0.5, delayFactor: 0.05)
        let animation = AnimationFactory.makeMoveUpWithBounce(rowHeight: 20, duration: 0.3, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: listView)
    }
}

// MARK: - UISearchBar Delegate

extension BreedListViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool  {
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //New Search breed result
        viewModel.searchsBreed_fromStorage(text: searchBar.text ?? "") { result in
            self.listView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Remove focus from the search bar.
        self.searchBar.endEditing(true)        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true)
        
        // Remove focus from the search bar.
        self.searchBar.endEditing(true)
        
        //Clear search result
        viewModel.clearSearchResult()
        
        self.listView.reloadData()
    }
}
