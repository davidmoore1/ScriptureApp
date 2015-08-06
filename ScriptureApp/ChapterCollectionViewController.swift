//
//  ChapterCollectionViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/7/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ChapterButtonCell"
private let sectionReuseIdentifier = "IntroductionCell"

class ChapterCollectionViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    var chapters = 0
    var selectedChapter = 0
    var introduction = false

    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!

    // MARK: - Actions

    @IBAction func selectIntroduction(sender: UIButton) {
        performSegueWithIdentifier("unwindIntroduction", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func selectChapter(sender: UIButton) {
        let cell = sender.superview?.superview as! ChapterCollectionViewCell
        selectedChapter = cell.chapter
        performSegueWithIdentifier("unwindChapter", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = scripture.getPopupBackgroundColor()
        popoverPresentationController?.backgroundColor = scripture.getPopupBackgroundColor()
        navigationItem.leftBarButtonItem?.title = scripture.getSearchCancelButtonTitle()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ChapterCollectionViewCell

        cell.chapter = indexPath.item + 1
        cell.button.setTitle("\(cell.chapter)", forState: .Normal)
        cell.button.backgroundColor = scripture.getChapterButtonBackgroundColor()
        cell.button.tintColor = scripture.getChapterButtonColor()
        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: sectionReuseIdentifier, forIndexPath: indexPath) as! IntroductionCollectionReusableView
        let title = scripture.getIntroductionTitle()
        view.button.setTitle(title, forState: .Normal)
        view.button.backgroundColor = scripture.getIntroductionButtonBackgroundColor()
        view.button.tintColor = scripture.getChapterButtonColor()
        return view
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if introduction {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        } else {
            return CGSizeZero
        }
    }
}

// MARK: - ChapterCollectionViewCell
class ChapterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    var chapter = 0
}

// MARK: - IntroductionCollectionReuseableView
class IntroductionCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var button: UIButton!
}
