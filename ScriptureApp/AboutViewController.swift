//
//  AboutViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/16/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class AboutViewController: CommonViewController {
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadHTMLString(scripture.getAboutHtml(), baseURL: nil)
        let bgColor = UIColorFromRGB(config.getViewerBackgroundColor())
        webView.backgroundColor = bgColor
        popoverPresentationController?.backgroundColor = bgColor
        navigationItem.title = scripture.getString(ALSScriptureStringId_MENU_ABOUT_)
        navigationItem.rightBarButtonItem?.title = scripture.getString(ALCCommonStringId_BUTTON_CLOSE_)
    }

}
