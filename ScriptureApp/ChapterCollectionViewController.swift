//
//  ChapterCollectionViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/7/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

let chapterReuseIdentifier = "ChapterButtonCell"
let introReuseIdentifier = "IntroductionCell"

class ChapterCollectionViewController: CommonViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var chapters = 0
    var selectedChapter = 0
    var introduction = false

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        popoverPresentationController?.passthroughViews = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = scripture.getPopupBackgroundColor()
        popoverPresentationController?.backgroundColor = scripture.getPopupBackgroundColor()
        navigationItem.leftBarButtonItem?.title = scripture.getString(ALSScriptureStringId_SEARCH_CANCEL_BUTTON_)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(chapterReuseIdentifier, forIndexPath: indexPath) as! ChapterCollectionViewCell

        cell.button.chapter = indexPath.item + 1
        cell.button.backgroundColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        cell.button.tintColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_BUTTON_, withNSString: ALCPropertyName_COLOR_))
        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: introReuseIdentifier, forIndexPath: indexPath) as! IntroductionCollectionReusableView
        let title = scripture.getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_TITLE_)
        view.button.setTitle(title, forState: .Normal)
        view.button.backgroundColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_INTRO_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_)!)
        view.button.tintColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_BUTTON_, withNSString: ALCPropertyName_COLOR_))
        return view
    }

    @IBAction func selectChapter(sender: ChapterButton) {
        selectedChapter = sender.chapter
        performSegueWithIdentifier("unwindChapter", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func selectIntroduction(sender: UIButton) {
        performSegueWithIdentifier("unwindIntroduction", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if introduction {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        } else {
            return CGSizeZero
        }
    }
}

class ChapterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: ChapterButton!
}

class ChapterButton: UIButton {
    var chapter = 0 {
        didSet {
            setTitle("\(chapter)", forState: .Normal)
        }
    }
}

class IntroductionCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var button: UIButton!
}