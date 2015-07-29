//
//  AboutViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/16/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!

    let scripture = Scripture.sharedInstance
    let config = Scripture.sharedInstance.getConfig()

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadHTMLString(scripture.getAboutHtml(), baseURL: nil)
        let bgColor = UIColorFromRGB(config.getViewerBackgroundColor())
        webView.backgroundColor = bgColor
        popoverPresentationController?.backgroundColor = bgColor
        navigationItem.title = scripture.getString(ALSScriptureStringId_MENU_ABOUT_)
        navigationItem.rightBarButtonItem?.title = scripture.getString(ALCCommonStringId_BUTTON_CLOSE_)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        popoverPresentationController?.passthroughViews = nil
        navbar?.updateNavigationBarColors()
        navbar?.barStyle = .Black
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        navbar?.updateNavigationBarColors()
    }
}
