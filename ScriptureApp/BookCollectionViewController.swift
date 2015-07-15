//
//  BookCollectionViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

let bookReuseIdentifier = "BookButtonCell"
let bookSectionReuseIdentifier = "BookSectionHeadingCell"

class BookCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var sectionBooks = [[String]]()
    var sectionHeadings = [String]()
    var selectedSection = 0
    var selectedBook = 0
    var bookIndex = 0
    
    override func viewDidLoad() {
        collectionView?.delegate = self
//        if let cvl = collectionViewLayout as? UICollectionViewFlowLayout {
//            cvl.estimatedItemSize = CGSize(width: 50, height: 50)
//        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sectionBooks.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionBooks[section].count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if sectionHeadings[section].isEmpty {
            return CGSizeZero
        } else {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bookReuseIdentifier, forIndexPath: indexPath) as! BookCollectionViewCell
        
        cell.button.section = indexPath.section
        cell.button.book = indexPath.item
        cell.button.setTitle(sectionBooks[cell.button.section][cell.button.book], forState: .Normal)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: bookSectionReuseIdentifier, forIndexPath: indexPath) as! BookSectionCollectionReusableView
        cell.label.text = sectionHeadings[indexPath.section]
        
        return cell
    }

    @IBAction func selectBook(sender: BookButton) {
        selectedSection = sender.section
        selectedBook = sender.book
        for section in 0..<selectedSection {
            bookIndex += sectionBooks[section].count
        }
        bookIndex += selectedBook
        
        performSegueWithIdentifier("unwindBook", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

class BookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: BookButton!
}

class BookButton: UIButton {
    var section = 0
    var book = 0
}

class BookSectionCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
}