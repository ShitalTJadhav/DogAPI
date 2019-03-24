//
//  PhotoCustomCell.swift
//  DogAPI
//
//  Created by Tushar  Jadhav on 2019-03-21.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit

class PhotoCustomCell: UICollectionViewCell {
    
    @IBOutlet weak var breedImageView: UIImageView!
    var updateImageInDbBlock: ((_ image: UIImage) -> Void)? = nil

    var model: BreedImage? {
        didSet {
            guard let model = model else {
                return
            }
            guard let imageData = model.breedImageData else {
                //Download image from server
                self.breedImage = AsyncImage(url: model.imageUrl ?? "")

                return
            }
            
            //Show store image
            breedImageView?.image = UIImage(data: imageData)
        }
    }
    
    var breedImage: AsyncImage? {
        didSet {
            guard let breedImage = breedImage else {
                return
            }
            
            breedImage.startDownload()
            breedImage.completeDownload = { [weak self] image in
                self?.alpha = 0
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.01 * Double(self?.tag ?? 0),
                    animations: {
                        self?.alpha = 1
                        if let image = image {
                            self?.breedImageView.image = image
                            self?.updateImageInDbBlock?(image)
                        }
                })
            }
        }
    }
    
    override func prepareForReuse() {
        breedImage?.completeDownload = nil
    }
}
