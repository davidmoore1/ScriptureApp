//
//  TextSizeViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/14/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class TextSizeViewController: CommonViewController, UIPopoverPresentationControllerDelegate {

    // MARK: - Properties

    var rootViewController: ScriptureViewController!

    // MARK: - IB Outlets

    @IBOutlet weak var slider: UISlider!

    // MARK: - Actions

    @IBAction func changeTextSize(sender: UISlider) {
        config.setFontSizeWithInt(Int32(sender.value))
        slider.value = Float(config.getFontSize())
        rootViewController.updateHtmlSize()
    }

    func selectTheme(sender: UIButton) {
        rootViewController.loadColorTheme(sender.currentTitle!)
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        createThemeButtons()
        preferredContentSize = getSize()

        slider.minimumValue = Float(config.getMinFontSize())
        slider.maximumValue = Float(config.getMaxFontSize())
        slider.value = Float(config.getFontSize())

        view.backgroundColor = scripture.getPopupBackgroundColor()
        popoverPresentationController?.backgroundColor = scripture.getPopupBackgroundColor()
    }

    // MARK: - UIPopoverPresentationControllerDelgate

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

   // MARK: - Misc

    func createThemeButtons() {
        let padding = CGFloat(10)
        let startX = padding
        let startY = slider.frame.origin.y + slider.frame.height
        let themes = scripture.getAvailableColorThemeNames()
        if themes.count < 2 {
            return
        }
        let totalPadding = themes.isEmpty ? padding : padding * CGFloat(themes.count + 1)
        let buttonWidth = (getSize().width - totalPadding) / CGFloat(themes.count)
        let buttonHeight = CGFloat(30)

        for (index, theme) in enumerate(themes) {
            let button = UIButton()
            button.frame = CGRectMake(startX + CGFloat(index) * buttonWidth + CGFloat(index) * padding, startY, buttonWidth, buttonHeight)
            button.setTitle(theme, forState: .Normal)
            button.setTitleColor(UIColor.clearColor(), forState: .Normal)
            button.backgroundColor = scripture.getThemeSelectorButtonBackgroundColorForTheme(theme)
            button.addTarget(self, action: "selectTheme:", forControlEvents: .TouchUpInside)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.grayColor().CGColor
            view.addSubview(button)
        }
    }

    func getSize() -> CGSize {
        let width = CGFloat(300)
        let buttonAndPaddingHeight = CGFloat(scripture.getAvailableColorThemeNames().count > 1 ? 40 : 0)
        let height = slider.frame.origin.y + slider.frame.height + buttonAndPaddingHeight
        return CGSizeMake(width, height)
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
