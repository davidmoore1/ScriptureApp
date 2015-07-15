//
//  Book.swift
//  ScriptureApp
//
//  Created by David Moore on 7/2/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

public class Book {
    private var mBook: ALSBook?
    var mIndex: Int?
    var mGroup: Int?
    var mGroupIndex: Int?
    var mBookGroupString: String?
    var mScripture: Scripture?
    private var mLastChapterRequested: Int
    
    public init (scripture: Scripture?, book: ALSBook?, index: Int?, group: Int?, groupIndex: Int?, groupString: String?) {
        mScripture = scripture
        mBook = book
        mIndex = index
        mGroup = group
        mGroupIndex = groupIndex
        mBookGroupString = groupString
        mLastChapterRequested = 0
    }
    func getBackgroundColor() -> UIColor {
        var style = mScripture!.useListView() ? ALSStyleName_UI_BOOK_BUTTON_LIST_ : ALSStyleName_UI_BOOK_BUTTON_GRID_
        var currentBookSubGroup = mBook!.getSubGroup()
        var colorTheme = mScripture!.getConfig().getCurrentColorTheme()
        var returnColorString = mScripture!.getConfig().getStylePropertyColorValueWithNSString(style, withNSString: ALCPropertyName_BACKGROUND_COLOR_)
        if ALCStringUtils_isNotBlankWithNSString_(currentBookSubGroup) {
            var backgroundStringColor = mScripture!.getConfig().getBookColorDefs().getColorStringFromNameWithNSString(currentBookSubGroup, withNSString: colorTheme)
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
    func getAbbrevName() -> String {
        return mBook!.getAbbrevName()
    }
    func getALSBook() -> ALSBook? {
        return mBook
    }
    func numberOfChapters() -> Int {
        // if config has feature hide empty chapters
        var retVal = -1
        if (mBook != nil) {
            retVal = Int(mBook!.getChapters().size())
        }
        return retVal
    }
    
    func getChapter(chapterNumber: Int) -> (success: Bool, chapter: String?) {
        var success = false
        var chapterString : String? = nil
        if ((chapterNumber <= numberOfChapters()) && (chapterNumber > 0)) {
            mLastChapterRequested = chapterNumber
            var iChapterNumber:CInt = CInt(chapterNumber)
            chapterString = mScripture!.getFactory().getChapterWithALSDisplayWriter(mScripture!.getDisplayWriter(), withALSBook: mScripture!.getLibrary().getCurrentBook(), withInt: iChapterNumber)
            success = true
        }
        return (success, chapterString)
    }
    func getIntroduction() -> (success: Bool, chapter: String?) {
        var success = false
        var chapterString : String? = nil
        if (hasIntroduction()) {
            mLastChapterRequested = 0
            chapterString = mScripture!.getFactory().getIntroductionWithALSDisplayWriter(mScripture!.getDisplayWriter(), withALSBook: mBook)
            success = true
        }
        return (success, chapterString)
    }
    func getCurrentChapterNumber() -> Int? {
        return mLastChapterRequested
    }
    func getNextChapter(webView: UIWebView) -> Bool {
        var nextChapterNumber = mLastChapterRequested + 1
        return mScripture!.goToReference(self, chapterNumber: nextChapterNumber, webView: webView)
    }
    func getPreviousChapter(webView: UIWebView) -> Bool {
        var previousChapterNumber = mLastChapterRequested - 1
        return mScripture!.goToReference(self, chapterNumber: previousChapterNumber, webView: webView)
    }
    func setLastChapter(chapterNumber: Int) {
        mLastChapterRequested = chapterNumber
    }
    func canGetChapter(number: Int) -> Bool {
        var lowThreshold = hasIntroduction() ? -1 : 0
        if let chapter = getCurrentChapterNumber() {
            var success = (number <= numberOfChapters()) && (number > lowThreshold)
            return success
        } else {
            return false
        }
    }
    
/*    func canGetNextChapter() -> Bool {
        if let chapter = getCurrentChapterNumber() {
            let success = getNextChapter()
            getChapter(chapter)
            return success
        } else {
            return false
        }
    }
    
    func canGetPreviousChapter() -> Bool {
        if let chapter = getCurrentChapterNumber() {
            let (success, _) = getPreviousChapter()
            getChapter(chapter)
            return success
        } else {
            return false
        }
    }*/
    func getFormattedBookChapter() -> String {
        var retString = getName()
        if (getCurrentChapterNumber() == 0) {
            retString = retString + " " + mScripture!.getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_TITLE_)
        } else {
            retString = retString + " " + String(getCurrentChapterNumber()!)
        }
        return retString
    }
    func hasIntroduction() -> Bool {
        return mBook!.hasIntroduction()
    }
    func sameBook(book: ALSBook) -> Bool {
        return book == mBook
    }
    private func runJavascript(jscript: String, webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString(jscript)
    }
    
    private func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}