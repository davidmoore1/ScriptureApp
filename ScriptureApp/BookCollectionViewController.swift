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
    var books = scripture.getBookArray()
    
    override func viewDidLoad() {
        collectionView?.delegate = self
        collectionView?.backgroundColor = scripture.getPopupBackgroundColor()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sectionBooks.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionBooks[section].count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // hide if empty or section titles not shown
        if !config.hasFeatureWithNSString(ALSScriptureFeatureName_BOOK_GROUP_TITLES_) || sectionHeadings[section].isEmpty {
            return CGSizeZero
        } else {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bookReuseIdentifier, forIndexPath: indexPath) as! BookCollectionViewCell
        let book = books[indexPath.section][indexPath.item]
        var title = book.getAbbrevName()
        if title.isEmpty {
            title = book.getName()
        }
        
        cell.button.section = indexPath.section
        cell.button.book = indexPath.item
        cell.button.setTitle(title, forState: .Normal)
        cell.button.backgroundColor = book.getBackgroundColor()
        cell.button.setTitleColor(book.getColor(), forState: .Normal)
        cell.button.titleLabel?.font = UIFont(name: "CharisSILCompact", size: 20)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: bookSectionReuseIdentifier, forIndexPath: indexPath) as! BookSectionCollectionReusableView
        let book = books[indexPath.section][indexPath.item]
        
        cell.label.text = book.mBookGroupString ?? ""
        
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