//
//  ScriptureViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/7/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class ScriptureViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    
    let scripture = Scripture()
    var scrollOffsetPrevious: CGFloat = 0
    var scrollOffsetNext: CGFloat = 0
    var scrollOffsetLoad: CGFloat = 0
    var point = CGPointZero
    var mVerseNumber: String = ""
    private var mAnnotationHtml: String = ""
    private var annotationWaiting: Bool = false
    private var book: Book?
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet var leftSwipe: UISwipeGestureRecognizer!
    @IBOutlet var rightSwipe: UISwipeGestureRecognizer!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bookButton: UIBarButtonItem!
    @IBOutlet weak var chapterButton: UIBarButtonItem!

    var bookNumber = 0 {
        didSet {
            book = scripture.getBookArray().flatMap { $0 }[bookNumber]
            bookButton.title = book!.getName() + Constants.UpArrow
            scripture.loadBook(book)
            scripture.updateCurrentBook(book)
            resetScrollOffsets()
            chapterNumber = 1
        }
    }
    
    var chapterNumber = 0 {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if (webView != nil) {
            scripture.goToReference(book!, chapterNumber: chapterNumber, webView: webView)
            if chapterNumber == 0 {
                let introTitle = scripture.getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_SYMBOL_)
                chapterButton.title = introTitle + Constants.UpArrow
            } else {
                chapterButton.title = "\(chapterNumber)" + Constants.UpArrow
            }
        }
    }
    
    func resetScrollOffsets() {
        scrollOffsetLoad = 0
        scrollOffsetPrevious = 0
        scrollOffsetNext = 0
    }
    
    func loadChapter(number: Int) {
        if book!.canGetChapter(number) {
            resetScrollOffsets()
            chapterNumber = number
        }
    }
    
    func loadNextChapter() {
        if book!.canGetNextChapter() {
            scrollOffsetPrevious = getOffset()
            chapterNumber++
            scrollOffsetLoad = scrollOffsetNext
            scrollOffsetNext = 0
        }
    }
    
    func loadPreviousChapter() {
        if book!.canGetPreviousChapter() {
            scrollOffsetNext = getOffset()
            chapterNumber--
            scrollOffsetLoad = scrollOffsetPrevious
            scrollOffsetPrevious = 0
        }
    }
    
    func getOffset() -> CGFloat {
        let y = webView.stringByEvaluatingJavaScriptFromString("window.pageYOffset")!.toInt()!
        let height = webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight")!.toInt()!
        let offset = CGFloat(y) / CGFloat(height)
        return offset
    }
    func setOffset(percent: CGFloat) {
        let height = webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight")!.toInt()!
        let x = webView.scrollView.contentOffset.x
        let y = percent * CGFloat(height)
        webView.stringByEvaluatingJavaScriptFromString("window.scrollTo(\(x), \(y))")
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        scrollOffsetLoad = getOffset()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        setOffset(scrollOffsetLoad)
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
        super.viewDidLoad()
        
        webView.delegate = self
        tap.delegate = self
        let singleTapSelector : Selector = "single:"
        let singleTap = UITapGestureRecognizer(target: self, action: singleTapSelector)
        singleTap.numberOfTapsRequired = 1
        singleTap.requireGestureRecognizerToFail(tap)
        singleTap.delegate = self
        
        webView.addGestureRecognizer(leftSwipe)
        webView.addGestureRecognizer(rightSwipe)
        webView.addGestureRecognizer(tap)
        webView.addGestureRecognizer(singleTap)
        
        scripture.loadLibrary()
        
        if (book == nil) {
            bookNumber = 0
        } else {
            updateUI()
        }
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
    @IBAction func single(sender:UITapGestureRecognizer) {
        if sender.state == .Ended {
            if annotationWaiting {
                point = sender.locationInView(webView)
                self.performSegueWithIdentifier(Constants.AnnotationSeque, sender: self)
                annotationWaiting = false
            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.SelectBook:
                let vc = segue.destinationViewController as! BookCollectionViewController
                vc.popoverPresentationController?.delegate = self
            case Constants.SelectChapter:
                let vc = segue.destinationViewController as! ChapterCollectionViewController
                vc.popoverPresentationController?.delegate = self
                vc.chapters = scripture.getCurrentBook()?.numberOfChapters() ?? 0
                vc.introduction = scripture.getCurrentBook()?.hasIntroduction() ?? false
            case Constants.AboutSeque:
                let vc = segue.destinationViewController as! UIViewController
                vc.popoverPresentationController?.delegate = self
            case Constants.SearchRequest:
                if let tvc = segue.destinationViewController.contentViewController as? SearchSelectViewController {
                    tvc.mScripture = scripture
                    tvc.mScriptureController = self
                }
            case Constants.TextSizeSeque:
                let vc = segue.destinationViewController as! TextSizeViewController
                vc.popoverPresentationController?.delegate = vc
            case Constants.AnnotationSeque:
                if let tvc = segue.destinationViewController.contentViewController as? AnnotationViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                        tvc.modalPresentationStyle = UIModalPresentationStyle.Popover
                        ppc.sourceRect = CGRect(x: point.x, y: point.y, width: 3, height: 3)
                    }
                    tvc.html = mAnnotationHtml
                }
            default: break
            }
       }
        
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        if (annotationWaiting) {
            annotationWaiting = false
            return UIModalPresentationStyle.None
        }
        return UIModalPresentationStyle.CurrentContext
    }
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let url = request.URL!.absoluteString
            mAnnotationHtml = scripture.getHtmlForAnnotation(url!)
            if !mAnnotationHtml.isEmpty {
                annotationWaiting = true
                return false
            }
        }
        return true
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        if mVerseNumber != "" {
            var result = scripture.goToVerse(mVerseNumber, webView: webView)
            result = scripture.highlightVerse(mVerseNumber, webView: webView)
            result = scripture.fadeElement(mVerseNumber, webView: webView)
            mVerseNumber = ""
        } else {
            setOffset(scrollOffsetLoad)
        }
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


extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        }
        return self
    }
}