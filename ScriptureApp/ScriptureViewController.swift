//
//  ScriptureViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/7/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class ScriptureViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    
    struct Constants {
        static let UP_ARROW = "▴"
        static let SELECT_BOOK_IDENTIFIER = "selectBook"
        static let SELECT_CHAPTER_IDENTIFIER = "selectChapter"
    }
    
    let scripture = Scripture()
    var scrollOffsetPrevious = CGPointZero
    var scrollOffsetNext = CGPointZero
    var scrollOffsetLoad = CGPointZero
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet var leftSwipe: UISwipeGestureRecognizer!
    @IBOutlet var rightSwipe: UISwipeGestureRecognizer!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bookButton: UIBarButtonItem!
    @IBOutlet weak var chapterButton: UIBarButtonItem!
    
    var bookNumber = 0 {
        didSet {
            let book = scripture.getBookArray().flatMap { $0 }[bookNumber]
            bookButton.title = book.getName() + Constants.UP_ARROW
            scripture.loadBook(book)
            scripture.updateCurrentBook(book)
            resetScrollOffsets()
            chapterNumber = 1
        }
    }
    
    var chapterNumber = 0 {
        didSet {
            if chapterNumber == 0 {
                loadIntroduction()
                chapterButton.title = "Intro" + Constants.UP_ARROW
            } else {
                let (success, htmlOptional) = scripture.getCurrentBook()!.getChapter(chapterNumber)
                if success {
                    if let html = htmlOptional {
                        webView.loadHTMLString(html, baseURL: nil)
                    }
                    chapterButton.title = "\(chapterNumber)" + Constants.UP_ARROW
                } else {
                    chapterNumber = oldValue
                }
            }
        }
    }
    
    func resetScrollOffsets() {
        scrollOffsetLoad = CGPointZero
        scrollOffsetPrevious = CGPointZero
        scrollOffsetNext = CGPointZero
    }
    
    func loadChapter(number: Int) {
        if scripture.canGetChapter(number) {
            resetScrollOffsets()
            chapterNumber = number
        }
    }
    
    func loadNextChapter() {
        if scripture.canGetNextChapter() {
            scrollOffsetPrevious = webView.scrollView.contentOffset
            chapterNumber++
            scrollOffsetLoad = scrollOffsetNext
            scrollOffsetNext = CGPointZero
        }
    }
    
    func loadPreviousChapter() {
        if scripture.canGetPreviousChapter() {
            scrollOffsetNext = webView.scrollView.contentOffset
            chapterNumber--
            scrollOffsetLoad = scrollOffsetPrevious
            scrollOffsetPrevious = CGPointZero
        }
    }
    
    func loadIntroduction() {
        let (success, htmlOptional) = scripture.getCurrentBook()!.getIntroduction()
        if success, let html = htmlOptional {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func toggleFullscreen() {
        navigationController?.setToolbarHidden(!navigationController!.toolbarHidden, animated: true)
    }
    
    override func viewDidLoad() {
        webView.delegate = self
        tap.delegate = self
        
        webView.addGestureRecognizer(leftSwipe)
        webView.addGestureRecognizer(rightSwipe)
        webView.addGestureRecognizer(tap)
        
        scripture.loadConfig()
        scripture.loadLibrary()
        bookNumber = 0
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func handleLeftSwipe(sender: UISwipeGestureRecognizer) {
        loadNextChapter()
    }
    @IBAction func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        loadPreviousChapter()
    }
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        toggleFullscreen()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Constants.SELECT_BOOK_IDENTIFIER {
                let vc = segue.destinationViewController as! BookCollectionViewController
                vc.popoverPresentationController?.delegate = self
                vc.sectionBooks = scripture.getBookArray().map { $0.map { self.getBookName($0) } }
                vc.sectionHeadings = scripture.getBookArray().map { $0.first!.mBookGroupString! }
            }
            if identifier == Constants.SELECT_CHAPTER_IDENTIFIER {
                let vc = segue.destinationViewController as! ChapterCollectionViewController
                vc.popoverPresentationController?.delegate = self
                vc.chapters = scripture.getCurrentBook()?.numberOfChapters() ?? 0
                vc.introduction = scripture.getCurrentBook()?.hasIntroduction() ?? false
            }
            if identifier == "about" {
                let vc = segue.destinationViewController as! UIViewController
                vc.popoverPresentationController?.delegate = self
            }
            if identifier == "search" {
                let nav = segue.destinationViewController as! UINavigationController
                let vc = nav.topViewController as! SearchViewController
                vc.rootNavigationController = navigationController
            }
            if identifier == "text size" {
                let vc = segue.destinationViewController as! TextSizeViewController
                vc.popoverPresentationController?.delegate = vc
            }
        }
        
    }
    
    func getBookName(book: Book) -> String {
        let name = book.getAbbrevName() ?? ""
        return name.isEmpty ? book.getName() : name
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.scrollView.setContentOffset(scrollOffsetLoad, animated: false)
    }
    
    @IBAction func cancelToScriptureViewController(segue: UIStoryboardSegue) {
        // do nothing
    }
    
    @IBAction func selectBook(segue: UIStoryboardSegue) {
        let vc = segue.sourceViewController as! BookCollectionViewController
        resetScrollOffsets()
        bookNumber = vc.bookIndex
    }
    
    @IBAction func selectChapter(segue: UIStoryboardSegue) {
        let vc = segue.sourceViewController as! ChapterCollectionViewController
        loadChapter(vc.selectedChapter)
    }
    
    @IBAction func selectIntroduction(segue: UIStoryboardSegue) {
        chapterNumber = 0
    }
    

}

extension Scripture {
    
    func canGetChapter(number: Int) -> Bool {
        if let book = getCurrentBook(), let chapter = book.getCurrentChapterNumber() {
            return chapter <= book.numberOfChapters() && chapter >= 0
        } else {
            return false
        }
    }
    
    func canGetNextChapter() -> Bool {
        if let book = getCurrentBook(), let chapter = book.getCurrentChapterNumber() {
            return canGetChapter(chapter + 1)
        } else {
            return false
        }
    }
    
    func canGetPreviousChapter() -> Bool {
        if let book = getCurrentBook(), let chapter = book.getCurrentChapterNumber() {
            return canGetChapter(chapter - 1)
        } else {
            return false
        }
    }
    
}