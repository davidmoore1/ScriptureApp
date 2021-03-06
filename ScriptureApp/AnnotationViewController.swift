//
//  AnnotationViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/26/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class AnnotationViewController: CommonViewController,
    UIWebViewDelegate
{
    private var popupHtml: String = ""
    private var popupLinks: ALSLinks?
    private var popoverPresentation = false
    var links: ALSLinks?

    @IBOutlet weak var mAnnotationWebView: UIWebView!

    var html: String = "" {
        didSet{
            if (mAnnotationWebView != nil) {
                // Load HTML from chapter into web view
                var url: NSURL = NSURL(string: scripture.mAssetsPath)!
                mAnnotationWebView.loadHTMLString(html, baseURL: url)
            }
        }
    }

    @IBAction func donePushed(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.presentingViewController!.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular) {
            // This view controller is running in a popover
            self.popoverPresentation = true
            self.navigationItem.rightBarButtonItem = nil; // remove the button
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mAnnotationWebView.delegate = self
        let bgColor = scripture.getFootnoteBackgroundColor()
        navigationItem.rightBarButtonItem?.title = scripture.getCloseButtonTitle()
        mAnnotationWebView.backgroundColor = bgColor
        popoverPresentationController?.backgroundColor = bgColor
        var url: NSURL = NSURL(string: scripture.mAssetsPath)!
        mAnnotationWebView.loadHTMLString(html, baseURL: url)
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
