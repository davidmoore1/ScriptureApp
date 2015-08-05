//
//  AnnotationViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/26/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class AnnotationViewController: CommonViewController {

    @IBOutlet weak var mAnnotationWebView: UIWebView!

    var html: String = "" {
        didSet{
            if (mAnnotationWebView != nil) {
                // Load HTML from chapter into web view
                mAnnotationWebView.loadHTMLString(html, baseURL: nil)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let bgColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString("body.footnote", withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        mAnnotationWebView.backgroundColor = bgColor
        popoverPresentationController?.backgroundColor = bgColor
        mAnnotationWebView.loadHTMLString(html, baseURL: nil)
    }

}
