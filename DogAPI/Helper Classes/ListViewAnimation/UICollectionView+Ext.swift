//
//  UICollectionView+Ext.swift
//  UICollectionViewCellAnimation-Article
//
//  Created by Vadym Bulavin on 9/4/18.
//  Copyright © 2018 Vadim Bulavin. All rights reserved.
//

import UIKit

extension UICollectionView {
	func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
		guard let lastIndexPath = indexPathsForSelectedItems?.last else {
			return false
		}

		return lastIndexPath == indexPath
	}
}
