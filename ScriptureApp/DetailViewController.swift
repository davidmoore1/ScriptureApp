//
//  DetailViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/11/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate, UIPopoverPresentationControllerDelegate {
    var html: String = "" {
        didSet{
            if (mWebView != nil) {
                // Load HTML from chapter into web view
                mWebView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    var mScripture: Scripture? = nil
    private var mAnnotationHtml: String = ""

    @IBOutlet weak var mWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.viewDidLoad()
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        // Load HTML from chapter into web view
        mWebView.delegate = self
        mWebView.loadHTMLString(html, baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private struct Constants {
        static let AnnotationSeque = "Annotation"
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        var success: Bool = false
        var chapterHtml: String? = nil
        if (mScripture != nil) {
            if (sender.direction == .Left) {
                (success, chapterHtml) = mScripture!.getNextChapter()
                if (success) {
                    navigationItem.title = mScripture!.getFormattedBookChapter()
                    html = chapterHtml!
                }
            }
            
            if (sender.direction == .Right) {
                (success, chapterHtml) = mScripture!.getPreviousChapter()
                if (success) {
                    navigationItem.title = mScripture!.getFormattedBookChapter()
                    html = chapterHtml!
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.AnnotationSeque:
                if let tvc = segue.destinationViewController as? AnnotationViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    tvc.html = mAnnotationHtml
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
