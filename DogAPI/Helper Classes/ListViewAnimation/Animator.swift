//
//  Animator.swift
//  UITableViewCellAnimation-Article
//
//  Created by Vadym Bulavin on 9/4/18.
//  Copyright © 2018 Vadim Bulavin. All rights reserved.
//

import UIKit

final class Animator {
	private var hasAnimatedAllCells = false
	private let animation: Animation

	init(animation: @escaping Animation) {
		self.animation = animation
	}

	func animate(cell: UICollectionViewCell, at indexPath: IndexPath, in collectionView: UICollectionView) {
		guard !hasAnimatedAllCells else {
			return
		}

		animation(cell, indexPath, collectionView)

		hasAnimatedAllCells = collectionView.isLastVisibleCell(at: indexPath)
	}
}
