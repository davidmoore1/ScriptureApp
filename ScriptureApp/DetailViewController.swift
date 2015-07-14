//
//  DetailViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/11/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate, UIPopoverPresentationControllerDelegate {
    var mSelectedVerse: String = ""
    var mSelectedBook: Book? = nil
    var mSelectedChapter: Int = 0 {
        didSet{
            if (mWebView != nil) {
                // Load HTML from chapter into web view
                if mScripture!.goToReference(mSelectedBook, chapterNumber: mSelectedChapter, webView: mWebView) {
                    navigationItem.title = mSelectedBook!.getFormattedBookChapter()
                }
            }
        }
    }
    var mScripture: Scripture?
    
    private var mAnnotationHtml: String = ""
    @IBOutlet weak var mWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        // Load HTML from chapter into web view
        mWebView.delegate = self
        if (mScripture == nil) {
            mScripture = Scripture()
            mScripture!.loadLibrary()
        }
        if mScripture!.goToReference(mSelectedBook, chapterNumber: mSelectedChapter, webView: mWebView) {
            navigationItem.title = mSelectedBook!.getFormattedBookChapter()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        var success: Bool = false
        var chapterHtml: String? = nil
        if (mScripture != nil) {
            var currentBook = mScripture!.getCurrentBook()
            if (sender.direction == .Left) {
                var success = currentBook!.getNextChapter(mWebView)
                if (success) {
                    navigationItem.title = currentBook!.getFormattedBookChapter()
                }
            }
            
            if (sender.direction == .Right) {
                var success = currentBook!.getPreviousChapter(mWebView)
                if (success) {
                    navigationItem.title = currentBook!.getFormattedBookChapter()
                }
            }
        }
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let url = request.URL!.absoluteString
            mAnnotationHtml = mScripture!.getHtmlForAnnotation(url!)
            if !mAnnotationHtml.isEmpty {
            self.performSegueWithIdentifier(Constants.AnnotationSeque, sender: self)
            return false
            }
        }
        return true
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        if mSelectedVerse != "" {
            var result = mScripture!.goToVerse(mSelectedVerse, webView: mWebView)
            result = mScripture!.highlightVerse(mSelectedVerse, webView: mWebView)
            mSelectedVerse = ""
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.AnnotationSeque:
                if let tvc = segue.destinationViewController.contentViewController as? AnnotationViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    tvc.html = mAnnotationHtml
                }
            case Constants.SearchRequest:
                if let tvc = segue.destinationViewController.contentViewController as? SearchSelectViewController {
                    tvc.mScripture = mScripture
                }
            case Constants.SelectBookSeque:
                if let tvc = segue.destinationViewController.contentViewController as? BookTableViewController {
                    tvc.mScripture = mScripture
                }
            default: break
            }
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!, traitCollection: UITraitCollection!) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
}
