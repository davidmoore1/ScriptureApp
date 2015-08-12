//
//  ImageAnnotationViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 8/11/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class ImageAnnotationViewController: CommonViewController
{

    var html: String = "" {
        didSet{
            if (webView != nil) {
                // Load HTML from chapter into web view
                var url: NSURL = NSURL(string: scripture.mAssetsPath)!
                webView.loadHTMLString(html, baseURL: url)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem?.title = scripture.getCloseButtonTitle()
        let bgColor = scripture.getFootnoteBackgroundColor()
        webView.backgroundColor = bgColor
        var url: NSURL = NSURL(string: scripture.mAssetsPath)!
        webView.loadHTMLString(html, baseURL: url)
    }

    @IBOutlet weak var webView: UIWebView!
    
}
