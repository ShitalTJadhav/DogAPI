//
//  BreedPhotoGalleryViewController.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-20.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class BreedPhotoGalleryViewController: UIViewController {

    @IBOutlet var listView: UICollectionView!
    let reuseIdentifier = "PhotoCellIdentifier"
    
    var breed : Breed!
    var viewModel : BreedGalleryViewModel!
    var menuView: BTNavigationDropdownMenu!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listView.dataSource = self
        listView.accessibilityIdentifier = "BreedGalleryViewIdentifier"

        //Show breed name on navigation title
        self.title = self.breed.breedname
        
        //Show sort by subbreed dropdown menu
        self.setUpSubbreedDropDownMenu()

        self.viewModel = BreedGalleryViewModel(breed: breed.breedname!, subbreed: breed.breedname!)
        print("Photos count : ",self.viewModel.currentCount)

        fetchBreedImages()
    }
    

    // MARK: - Setup / Private methods
    
    func setUpSubbreedDropDownMenu(){
        
        guard let breedname = breed.breedname else {
            return
        }
        
        var items = ["All Breed - \(breedname)"]
        
        for value in self.breed?.subbreed ?? [] {
            
            let model = value as! SubBreed
            guard let subBreedName = model.subBreedname else { return }
            print("Subbreed : ",subBreedName)
            items.append(subBreedName)
        }
        
        if items.count > 1 {
            
            menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.index(0), items: items)
            
            menuView.cellHeight = 50
            menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
            menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
            menuView.shouldKeepSelectedCellColor = true
            menuView.cellTextLabelColor = UIColor.white
            menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
            menuView.cellTextLabelAlignment = .left // .Center // .Right // .Left
            menuView.arrowPadding = 15
            menuView.animationDuration = 0.5
            menuView.maskBackgroundColor = UIColor.black
            menuView.maskBackgroundOpacity = 0.3
            menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> Void in
                
                //Fetch image by subbreed
                self.viewModel.subBreedType = indexPath == 0 ? breedname : items[indexPath]
                self.viewModel.fetchBreedImage_fromStorage()
                self.listView.reloadData()
            }
            
            menuView.accessibilityIdentifier = "Subbreed_Menu"
            self.navigationItem.titleView = menuView
        }

    }
    
    fileprivate func fetchBreedImages() {
        
        viewModel.fetchBreedImages_fromServer({[unowned self] result in
            switch result {
            case .failure:break
            case .success:
                DispatchQueue.main.async {
                    self.listView?.reloadData()
                }
            }
        })
    }
}

// MARK: - UITableViewDataSource

extension BreedPhotoGalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCustomCell
        cell.tag = indexPath.item
        cell.model = viewModel.list[indexPath.row]

        //Handle image download events
        cell.updateImageInDbBlock = { image in
            self.viewModel.storageManager.updateBreedImages(image: image, breedType: self.breed.breedname!, imageUrl: cell.model?.imageUrl ?? "")
        }
        return cell
    }
}
