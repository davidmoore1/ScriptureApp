//
//  Misc.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/15/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation
import UIKit


func updateGlobalUIFromConfig() {
    //// color strings
    // taken from DefaultColors.java
    let colorNames = [
        "TextColor", "TitlesColor", "BackgroundColor", "VerseNumberColor", "FootnoteBackgroundColor", "PopupBackgroundColor", "TextHighlightColor",
        "LinkColor", "FooterBackgroundColor",
        "ChapterButtonColor", "ChapterButtonTextColor", "ChapterButtonIntroColor",
        "BookListDefaultColor", "BookButtonDefaultColor", "BookButtonTextColor",
        "SearchTextColor", "SearchButtonColor", "SearchButtonTextColor", "SearchProgressButtonColor", "SearchProgressButtonTextColor",
        "ActionBarTopColor", "ActionBarBottomColor",
        "AudioBarTopColor", "AudioBarBottomColor", "AudioBarTopLine1Color", "AudioBarTopLine2Color",
        "VerseBlock1Color", "VerseBlock2Color"
    ]
    let theme = config.getCurrentColorTheme()
    var colors = [String: UIColor]()
    for name in colorNames {
        colors[name] = UIColorFromRGB(config.getColorDefs().getColorStringFromNameWithNSString(name, withNSString: theme))
    }
    
}

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

// modified from http://www.anthonydamota.me/blog/en/use-a-hex-color-code-with-uicolor-on-swift/
func UIColorFromRGB(var colorCode: String, alpha: Float = 1.0) -> UIColor {
    if colorCode.hasPrefix("#") { colorCode.removeAtIndex(colorCode.startIndex) }
    var scanner = NSScanner(string:colorCode)
    var color:UInt32 = 0;
    scanner.scanHexInt(&color)
    
    let mask = 0x000000FF
    let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
    let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
    let b = CGFloat(Float(Int(color) & mask)/255.0)
    
    return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
}