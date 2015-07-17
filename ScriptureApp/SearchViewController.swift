//
//  SearchViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/14/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var rootNavigationController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootNavigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        rootNavigationController?.setNavigationBarHidden(true, animated: true)
    }
}