//
//  BreedListViewCell.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-19.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit

class BreedListViewCell: UICollectionViewCell {
    
    @IBOutlet weak var breedNameLabel: UILabel!


    var model: Breed? {
        didSet {
            guard let model = model else {
                return
            }
            breedNameLabel.text = model.breedname
                        
            //Show cell background color
            if self.tag % 2 == 0 {
                self.backgroundColor = ColorPalette.appDarkColor
            }
            else {
                self.backgroundColor = ColorPalette.applightColor
                
            }
        }
    }
    
    override func awakeFromNib() {
        self.layoutIfNeeded()

        
    }
}
