//
//  BookCollectionViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BookButtonCell"
private let sectionReuseIdentifier = "BookSectionHeadingCell"

class BookCollectionViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    var bookIndex = 0
    var books = Scripture.sharedInstance.getBookArray()

    // MARK: - IB Outlets

    @IBOutlet var collectionView: UICollectionView!

    // MARK: - IB Actions

    @IBAction func selectBook(sender: UIButton) {
        let cell = sender.superview?.superview as! BookCollectionViewCell
        let selectedSection = cell.section
        let selectedBook = cell.book
        for section in 0..<selectedSection {
            bookIndex += books[section].count
        }
        bookIndex += selectedBook
        performSegueWithIdentifier("unwindBook", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.backgroundColor = scripture.getPopupBackgroundColor()
        popoverPresentationController?.backgroundColor = scripture.getPopupBackgroundColor()
        navigationItem.leftBarButtonItem?.title = scripture.getString(ALSScriptureStringId_SEARCH_CANCEL_BUTTON_)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return books.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books[section].count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BookCollectionViewCell
        let book = books[indexPath.section][indexPath.item]

        cell.section = indexPath.section
        cell.book = indexPath.item
        cell.button.setTitle(book.getButtonTitle(), forState: .Normal)
        if !scripture.useListView() {
            cell.button.backgroundColor = book.getBackgroundColor()
        } else {
            cell.button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
        cell.button.setTitleColor(book.getColor(), forState: .Normal)

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: sectionReuseIdentifier, forIndexPath: indexPath) as! BookSectionCollectionReusableView
        let book = books[indexPath.section][indexPath.item]

        cell.label.text = book.mBookGroupString!
        cell.label.textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_BOOK_GROUP_TITLE_, withNSString: ALCPropertyName_COLOR_))

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flow = collectionViewLayout as! UICollectionViewFlowLayout
        if scripture.useListView() {
            let width = collectionView.bounds.size.width - flow.sectionInset.left - flow.sectionInset.right
            let height = UIButton().intrinsicContentSize().height
            return CGSizeMake(width, height)
        } else {
            return flow.itemSize
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // hide if empty or section titles not shown
        if !config.hasFeatureWithNSString(ALSScriptureFeatureName_BOOK_GROUP_TITLES_) || books[section].first!.mBookGroupString!.isEmpty {
            return CGSizeZero
        } else {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        }
    }

}

// MARK: - BookCollectionViewCell
class BookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    var section = 0
    var book = 0
}

// MARK: - BookSectionCollectionReuseableView
class BookSectionCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
}

extension Book {
    func getButtonTitle() -> String {
        if mScripture!.useListView() {
            return getName()
        } else {
            let abbrev = getAbbrevName()
            return abbrev.isEmpty ? getName() : abbrev
        }
    }
}
