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

class ChapterCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var chapters = 0
    var selectedChapter = 0
    var introduction = false
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(chapterReuseIdentifier, forIndexPath: indexPath) as! ChapterCollectionViewCell
        
        cell.button.chapter = indexPath.item + 1
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: introReuseIdentifier, forIndexPath: indexPath) as! IntroductionCollectionReusableView
        view.button.setTitle("Introduction", forState: .Normal)
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