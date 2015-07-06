//
//  Book.swift
//  ScriptureApp
//
//  Created by David Moore on 7/2/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

public class Book {
    var mBook: ALSBook?
    var mIndex: Int?
    var mGroup: Int?
    var mGroupIndex: Int?
    var mBookGroupString: String?
    var mScripture: Scripture?
    
    public init (scripture: Scripture?, book: ALSBook?, index: Int?, group: Int?, groupIndex: Int?, groupString: String?) {
        mScripture = scripture
        mBook = book
        mIndex = index
        mGroup = group
        mGroupIndex = groupIndex
        mBookGroupString = groupString
    }
    func getBackgroundColor() -> UIColor {
        var style = mScripture!.useListView() ? ALSStyleName_UI_BOOK_BUTTON_LIST_ : ALSStyleName_UI_BOOK_BUTTON_GRID_
        var currentBookSubGroup = mBook!.getSubGroup()
        var colorTheme = mScripture!.getConfig().getCurrentColorTheme()
        var returnColorString = mScripture!.getConfig().getStylePropertyColorValueWithNSString(style, withNSString: ALCPropertyName_BACKGROUND_COLOR_)
        if ALCStringUtils_isNotBlankWithNSString_(currentBookSubGroup) {
            var backgroundStringColor = mScripture!.getConfig().getColorDefs().getColorStringFromNameWithNSString(currentBookSubGroup, withNSString: colorTheme)
            if ALCStringUtils_isNotBlankWithNSString_(backgroundStringColor) {
                returnColorString = backgroundStringColor
            }
        }
        if (returnColorString.hasPrefix("#")) {
            returnColorString.removeAtIndex(returnColorString.startIndex)
        } else {
            returnColorString = "e8e8e8"
        }
        let backgroundColor = UIColorFromRGB(UInt(strtoul(returnColorString, nil, 16)))
        return backgroundColor
    }
    func getName() -> String {
        return mBook!.getName()
    }
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}