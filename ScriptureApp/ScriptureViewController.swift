//
//  ScriptureViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/7/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class ScriptureViewController: CommonViewController,
    UIWebViewDelegate,
    UIGestureRecognizerDelegate,
    UIPopoverPresentationControllerDelegate
{
    // MARK: - Properties

    // private properties
    private var scrollOffsetPrevious: CGFloat = 0
    private var scrollOffsetNext: CGFloat = 0
    private var scrollOffsetLoad: CGFloat = 0
    private var point = CGPointZero
    private var mAnnotationHtml: String = ""
    private var annotationWaiting: Bool = false
    private var book: Book?
    private var pinchBeginFontSize = CGFloat(0)
    private var firstAppearance = true
    private let prefs = NSUserDefaults.standardUserDefaults()

    // public properties
    var mVerseNumber: String = ""
    var bookNumber = 0 {
        didSet {
            book = scripture.getBookArray().flatMap { $0 }[bookNumber]
            bookButton.title = book!.getName() + Constants.Arrow
            resetScrollOffsets()
            chapterNumber = 1
            prefs.setInteger(bookNumber, forKey: Constants.BookNumberKey)
        }
    }

    var chapterNumber = 0 {
        didSet {
            updateUI()
            prefs.setInteger(chapterNumber, forKey: Constants.ChapterNumberKey)
        }
    }

    // MARK: - IB Outlets

    @IBOutlet private var tap: UITapGestureRecognizer!
    @IBOutlet private var leftSwipe: UISwipeGestureRecognizer!
    @IBOutlet private var rightSwipe: UISwipeGestureRecognizer!
    @IBOutlet private var pinch: UIPinchGestureRecognizer!
    @IBOutlet private weak var webView: UIWebView!
    @IBOutlet var closeButton: UIBarButtonItem!

    @IBOutlet private weak var bookButton: UIBarButtonItem!
    @IBOutlet private weak var chapterButton: UIBarButtonItem!
    @IBOutlet private weak var space: UIBarButtonItem!
    @IBOutlet private weak var searchButton: UIBarButtonItem!
    @IBOutlet private weak var fixedSpace1: UIBarButtonItem!
    @IBOutlet private weak var textSizeButton: UIBarButtonItem!
    @IBOutlet private weak var fixedSpace2: UIBarButtonItem!
    @IBOutlet private weak var aboutButton: UIBarButtonItem!

    // MARK: - IB Actions

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

    @IBAction func handlePinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .Began {
            pinchBeginFontSize = CGFloat(config.getFontSize())
        }
        let factor: CGFloat = 0.5
        let scale = sender.scale * factor + (1 - factor)
        config.setFontSizeWithInt(Int32(pinchBeginFontSize * scale))
        updateHtmlSize()
    }

    // MARK: - Scripture Navigation

    func loadIntroduction() {
        let (success, htmlOptional) = scripture.getCurrentBook()!.getIntroduction()
        if success, let html = htmlOptional {
            webView.loadHTMLString(html, baseURL: nil)
        }
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

    // MARK: - UI Changes

    func updateUI() {
        if (webView != nil) {
            scripture.goToReference(book!, chapterNumber: chapterNumber, webView: webView)
            if chapterNumber == 0 {
                let introTitle = scripture.getIntroductionSymbol()
                chapterButton.title = introTitle + Constants.Arrow
            } else {
                chapterButton.title = "\(chapterNumber)" + Constants.Arrow
            }
        }
    }

    func resetScrollOffsets() {
        scrollOffsetLoad = 0
        scrollOffsetPrevious = 0
        scrollOffsetNext = 0
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

    func toggleFullscreen() {
        if Constants.BarOnTop {
            navigationController?.setNavigationBarHidden(!navigationController!.navigationBarHidden, animated: true)
        } else {
            navigationController?.setToolbarHidden(!navigationController!.toolbarHidden, animated: true)
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Color Theme and Font Size

    func loadColorTheme(theme: String) {
        loadColorTheme(theme, navigationBar: nil)
    }

    func loadColorTheme(theme: String, navigationBar: UINavigationBar?) {
        config.setCurrentColorThemeWithNSString(theme)
        updateBarTheme()
        view.backgroundColor = scripture.getViewerBackgroundColor()
        webView.backgroundColor = scripture.getViewerBackgroundColor()
        updateHtmlColors()
    }

    func updateHtmlColors() {
        var js = ""
        for style in config.getStyles().map({ $0 as! ALCStyle }) {
            let styleName = style.getName()
            if style.hasPropertyWithNSString("color") {
                let colorStr = scripture.getColorStringFromStyle(styleName)
                js += "ss.addRule('\(styleName)', 'color: \(colorStr)');"
            }
            if style.hasPropertyWithNSString("background-color") {
                let colorStr = scripture.getBackgroundColorStringFromStyle(styleName)
                js += "ss.addRule('\(styleName)', 'background-color: \(colorStr)');"
            }
        }
        js = "(function changeColors() { ss = document.styleSheets[0]; \(js) })()"
        webView.stringByEvaluatingJavaScriptFromString(js)
    }

    func updateHtmlSize() {
        let fontSize = config.getFontSize()
        var js = "(function changeFontSize() { var el = document.getElementsByTagName('body')[0].style.fontSize = '\(fontSize)px'; })()"
        webView.stringByEvaluatingJavaScriptFromString(js)
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        let items = [bookButton, chapterButton, space, searchButton, fixedSpace1, textSizeButton, fixedSpace2, aboutButton]
        navigationItem.leftBarButtonItems = items
        webView.delegate = self
        tap.delegate = self
        let singleTapSelector : Selector = "single:"
        let singleTap = UITapGestureRecognizer(target: self, action: singleTapSelector)
        singleTap.numberOfTapsRequired = 1
        singleTap.requireGestureRecognizerToFail(tap)
        singleTap.delegate = self
        searchButton.enabled = scripture.hasFeatureSearch()

        webView.addGestureRecognizer(leftSwipe)
        webView.addGestureRecognizer(rightSwipe)
        webView.addGestureRecognizer(tap)
        webView.addGestureRecognizer(singleTap)
        webView.addGestureRecognizer(pinch)

        closeButton.title = ""
        navigationItem.backBarButtonItem = closeButton
        loadColorTheme(config.getCurrentColorTheme())
        if !restoreReference() {
            if (book == nil) {
                bookNumber = scripture.firstBookIndex
            } else {
                updateUI()
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if firstAppearance {
            checkExpiry()
            firstAppearance = false
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition( { _ -> Void in self.scrollOffsetLoad = self.getOffset() },
                                    completion: { _ -> Void in self.setOffset(self.scrollOffsetLoad) })
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func prefersStatusBarHidden() -> Bool {
        if let navHid = navigationController?.navigationBarHidden {
            return navHid || super.prefersStatusBarHidden()
        } else {
            return super.prefersStatusBarHidden()
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
                    tvc.mScriptureController = self
                }
            case Constants.TextSizeSeque:
                let vc = segue.destinationViewController as! TextSizeViewController
                vc.rootViewController = self
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

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - UIWebViewDelegate

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
        updateHtmlSize()
        updateHtmlColors()
        if mVerseNumber != "" {
            var result = scripture.goToVerse(mVerseNumber, webView: webView)
            result = scripture.highlightVerse(mVerseNumber, webView: webView)
            result = scripture.fadeElement(mVerseNumber, webView: webView)
            mVerseNumber = ""
        } else {
            setOffset(scrollOffsetLoad)
        }
    }

    // MARK: - UIPopoverPresentationControllerDelegate

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

    // MARK: - Misc

    func checkExpiry() {
        let expiry = config.getExpiry()
        if scripture.hasExpired() {
            scripture.loadExpiryMessage()
            let message = expiry.getMessage()
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            if !expiry.isStopOnExpiry() {
                let close = UIAlertAction(title: scripture.getCloseButtonTitle(), style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(close)
            }
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    func restoreReference() -> Bool {
        if let bookNum = prefs.objectForKey(Constants.BookNumberKey) as? Int {
            if let chapterNum = prefs.objectForKey(Constants.ChapterNumberKey) as? Int {
                bookNumber = bookNum
                chapterNumber = chapterNum
                return true
            }
        }
        return false
    }
}

// MARK: - UIViewController
extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        }
        return self
    }
}
