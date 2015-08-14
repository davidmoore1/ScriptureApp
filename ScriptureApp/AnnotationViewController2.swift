//
//  AnnotationViewController2.swift
//  ScriptureApp
//
//  Created by David Moore on 8/14/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class AnnotationViewController2: CommonViewController, UIWebViewDelegate {

    @IBOutlet weak var mAnnotationWebView: UIWebView!
    private var popupHtml: String = ""
    private var popupLinks: ALSLinks?
    var popoverPresentation: Bool = false
    var links: ALSLinks?
    var html: String = "" {
        didSet{
            if (mAnnotationWebView != nil) {
                // Load HTML from chapter into web view
                var url: NSURL = NSURL(string: scripture.mAssetsPath)!
                mAnnotationWebView.loadHTMLString(html, baseURL: url)
            }
        }
    }
    
    override var preferredContentSize: CGSize {
        get {
            if mAnnotationWebView != nil && presentingViewController != nil {
                return mAnnotationWebView.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mAnnotationWebView.delegate = self
        let bgColor = scripture.getFootnoteBackgroundColor()
        mAnnotationWebView.backgroundColor = bgColor
        if popoverPresentation {
            // This view is running in a popover
            self.navigationItem.rightBarButtonItem = nil; // remove the button
        } else {
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "barButtonItemClicked:"), animated: true)
        }
        popoverPresentationController?.backgroundColor = bgColor
        var url: NSURL = NSURL(string: scripture.mAssetsPath)!
        mAnnotationWebView.loadHTMLString(html, baseURL: url)
    }
    func barButtonItemClicked(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let url = request.URL!.absoluteString
            let results = scripture.getHtmlForAnnotation(url!, links: links!)
            if !results.results.getHtml().isEmpty {
                var newController = AnnotationViewController2(nibName: "AnnotationViewController2", bundle: nil)
                newController.popoverPresentation = popoverPresentation
                newController.links = results.popupLinks
                newController.html = results.results.getHtml()
                self.navigationController?.pushViewController(newController, animated: true)
            }
        }
        return true
    }
    


}
