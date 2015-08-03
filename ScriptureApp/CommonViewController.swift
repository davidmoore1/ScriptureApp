//
//  CommonViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/29/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController {

    let scripture = Scripture.sharedInstance
    let config = Scripture.sharedInstance.getConfig()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateBarTheme()
    }

    func updateBarTheme() {
        if let navbar = navigationController?.navigationBar {
            navbar.translucent = false
            navbar.barStyle = UIBarStyle.Black
            navbar.tintColor = UIColor.whiteColor()
            navbar.barTintColor = scripture.getBarBackgroundColor()
        }
    }

}

extension Scripture {
    func getBarBackgroundColor() -> UIColor {
        let topColor = getActionBarTopColor()
        let bottomColor = getActionBarBottomColor()
        return getMidColor(topColor, bottomColor)
    }
}
