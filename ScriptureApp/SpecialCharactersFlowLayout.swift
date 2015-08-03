//
//  SpecialCharactersFlowLayout.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/27/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SpecialCharactersFlowLayout: UICollectionViewFlowLayout {
    let specialCharacters = Scripture.sharedInstance.getSpecialCharacters()
    let cellWidth = CGFloat(50)
    let cellHeight = CGFloat(50)

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var indexPaths = [NSIndexPath]()
        for section in 0..<specialCharacters.count {
            for item in 0..<specialCharacters[section].count {
                indexPaths.append(NSIndexPath(forItem: item, inSection: section))
            }
        }
        return indexPaths.map { self.layoutAttributesForItemAtIndexPath($0) }
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return setCellPosition(super.layoutAttributesForItemAtIndexPath(indexPath))
    }

    override func collectionViewContentSize() -> CGSize {
        let width = specialCharacters.isEmpty ? CGFloat(0) : maxElement(specialCharacters.map { CGFloat($0.count) * self.cellWidth })
        let height = CGFloat(specialCharacters.count) * cellHeight
        return CGSizeMake(width, height)
    }

    func setCellPosition(attrs: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let indexPath = attrs.indexPath
        let x = self.cellWidth * CGFloat(indexPath.item)
        let y = self.cellHeight * CGFloat(indexPath.section)
        attrs.frame = CGRectMake(x, y, self.cellWidth, self.cellHeight)
        return attrs
    }

}
