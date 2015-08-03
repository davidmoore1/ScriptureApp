//
//  Misc.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/15/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation
import UIKit

func getMidColor(color1: UIColor, color2: UIColor) -> UIColor {
    func mid(f1: CGFloat, f2: CGFloat) -> CGFloat {
        return (f1 + f2) / 2
    }
    var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0
    var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0
    color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    return UIColor(red: mid(r1, r2), green: mid(g1, g2), blue: mid(b1, b2), alpha: mid(a1, a2))
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
