//
//  BreedListViewController.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit

class BreedListViewController: UIViewController {

    @IBOutlet var listView: UICollectionView!
    let reuseIdentifier = "BreedListIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set list view
        setUpCollectionView()
        
    
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
}

extension BreedListViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BreedListViewCell
        //cell.backgroundColor = .red
        // Configure the cell
        cell.breedNameLabel.text = "TEST"
        
        return cell
    }
}
