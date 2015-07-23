//
//  ScriptureViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/7/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class ScriptureViewController: UIViewController,
    UIWebViewDelegate,
    UIGestureRecognizerDelegate,
    UIPopoverPresentationControllerDelegate
{
    var scrollOffsetPrevious: CGFloat = 0
    var scrollOffsetNext: CGFloat = 0
    var scrollOffsetLoad: CGFloat = 0
    var point = CGPointZero
    var mVerseNumber: String = ""
    private var mAnnotationHtml: String = ""
    private var annotationWaiting: Bool = false
    private var book: Book?
    var pinchBeginFontSize = CGFloat(0)
    let scripture = Scripture.sharedInstance
    let config = Scripture.sharedInstance.getConfig()

    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet var leftSwipe: UISwipeGestureRecognizer!
    @IBOutlet var rightSwipe: UISwipeGestureRecognizer!
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    @IBOutlet weak var webView: UIWebView!

    @IBOutlet weak var bookButton: UIBarButtonItem!
    @IBOutlet weak var chapterButton: UIBarButtonItem!
    @IBOutlet weak var space: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var fixedSpace1: UIBarButtonItem!
    @IBOutlet weak var textSizeButton: UIBarButtonItem!
    @IBOutlet weak var fixedSpace2: UIBarButtonItem!
    @IBOutlet weak var aboutButton: UIBarButtonItem!

    var bookNumber = 0 {
        didSet {
            book = scripture.getBookArray().flatMap { $0 }[bookNumber]
            bookButton.title = book!.getName() + Constants.Arrow
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
        updateToolbarColors()
        navbar?.updateNavigationBarColors()
    }

    func loadIntroduction() {
        let (success, htmlOptional) = scripture.getCurrentBook()!.getIntroduction()
        if success, let html = htmlOptional {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        if let navHid = navigationController?.navigationBarHidden, let toolHid = navigationController?.toolbarHidden {
            return (navHid && toolHid) || super.prefersStatusBarHidden()
        } else {
            return super.prefersStatusBarHidden()
        }
    }

    func toggleFullscreen() {
        if Constants.BarOnTop {
            navigationController?.setNavigationBarHidden(!navigationController!.navigationBarHidden, animated: true)
        } else {
            navigationController?.setToolbarHidden(!navigationController!.toolbarHidden, animated: true)
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.toolbarHidden = Constants.BarOnTop
        navigationController?.navigationBarHidden = !Constants.BarOnTop
        if Constants.BarOnTop {
            navigationController?.navigationBar.barStyle = UIBarStyle.Black
            navigationItem.leftBarButtonItems = [bookButton, chapterButton, space, searchButton, fixedSpace1, textSizeButton, fixedSpace2, aboutButton]
        }
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
        webView.addGestureRecognizer(pinch)

        if (book == nil) {
            bookNumber = 0
        } else {
            updateUI()
        }

        loadColorTheme(config.getCurrentColorTheme())
    }

    func updateToolbarColors() {
        let topColor = scripture.getActionBarTopColor()
        let bottomColor = scripture.getActionBarBottomColor()
        let midColor = getMidColor(topColor, bottomColor)

        let gradient = CAGradientLayer()
        let toolbar = navigationController!.toolbar

        gradient.frame = toolbar.bounds
        gradient.colors = Constants.UseGradient ? [topColor.CGColor, bottomColor.CGColor] : [midColor.CGColor, midColor.CGColor]
        gradient.name = Constants.GradientName

        toolbar.layer.removeSublayer(name: Constants.GradientName)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        toolbar.backgroundColor = UIColor.clearColor()
        toolbar.layer.insertSublayer(gradient, atIndex: 0)
        toolbar.tintColor = UIColor.whiteColor()
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
    @IBAction func handlePinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .Began {
            pinchBeginFontSize = CGFloat(config.getFontSize())
        }
        let factor: CGFloat = 0.5
        let scale = sender.scale * factor + (1 - factor)
        config.setFontSizeWithInt(Int32(pinchBeginFontSize * scale))
        updateHtmlSize()
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

    func loadColorTheme(theme: String) {
        loadColorTheme(theme, navigationBar: nil)
    }

    func loadColorTheme(theme: String, navigationBar: UINavigationBar?) {
        config.setCurrentColorThemeWithNSString(theme)
        updateToolbarColors()
        view.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        webView.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        navigationBar?.updateNavigationBarColors()
        navigationController?.navigationBar.updateNavigationBarColors()
        updateHtmlColors()
    }

    func updateHtmlColors() {
        var js = ""
        for style in config.getStyles().map({ $0 as! ALCStyle }) {
            let styleName = style.getName()
            if style.hasPropertyWithNSString("color") {
                let colorStr = config.getStylePropertyColorValueWithNSString(styleName, withNSString: ALCPropertyName_COLOR_)
                js += "ss.addRule('\(styleName)', 'color: \(colorStr)');"
            }
            if style.hasPropertyWithNSString("background-color") {
                let colorStr = config.getStylePropertyColorValueWithNSString(styleName, withNSString: ALCPropertyName_BACKGROUND_COLOR_)
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
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        }
        return self
    }

    var navbar: UINavigationBar? {
        return navigationController?.navigationBar
    }
}

extension UINavigationBar {
    func updateNavigationBarColors() {
        let scripture = Scripture.sharedInstance
        let topColor = scripture.getActionBarTopColor()
        let bottomColor = scripture.getActionBarBottomColor()
        let midColor = getMidColor(topColor, bottomColor)

        tintColor = UIColor.whiteColor()
        setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.DefaultPrompt)

        let gradient = CAGradientLayer()
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        gradient.frame = CGRectMake(0, -statusBarFrame.height, bounds.width, statusBarFrame.height + bounds.height)
        gradient.colors = (Constants.UseGradient ? [topColor, bottomColor] : [midColor, midColor]).map { $0.CGColor }
        gradient.name = Constants.GradientName

        layer.removeSublayer(name: Constants.GradientName)
        backgroundColor = UIColor.clearColor()
        layer.insertSublayer(gradient, atIndex: 0)
        titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
}

extension CALayer {
    func removeSublayer(#name: String) {
        if sublayers != nil {
            for layer in sublayers as! [CALayer] {
                if layer.name != nil && layer.name == name {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
}

extension Scripture {

    func getActionBarTopColor() -> UIColor {
        return UIColorFromRGB(getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_UI_ACTION_BAR_, withNSString: ALCPropertyName_COLOR_TOP_))
    }

    func getActionBarBottomColor() -> UIColor {
        return UIColorFromRGB(getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_UI_ACTION_BAR_, withNSString: ALCPropertyName_COLOR_BOTTOM_))
    }
}