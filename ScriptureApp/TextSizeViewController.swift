//
//  TextSizeViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/14/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class TextSizeViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    override func viewDidLoad() {
        preferredContentSize.height = getViewHeight()
    }
    
    func getViewHeight() -> CGFloat {
        var lowestPoint: CGFloat = 0
        for v in view.subviews as! [UIView] {
            let low = v.frame.origin.y + v.frame.height
            lowestPoint = max(lowestPoint, low)
        }
        return lowestPoint
    }
}
