//
//  Book.swift
//  ScriptureApp
//
//  Created by David Moore on 7/2/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

public class Book {

    // MARK: - Properties and initialization

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

    func getALSBook() -> ALSBook? {
        return mBook
    }

    // MARK: - Color theme

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

    func getColor() -> UIColor {
        var colorStr = mScripture!.getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_UI_BOOK_BUTTON_GRID_, withNSString: ALCPropertyName_COLOR_)
        var color: UIColor
        if ALCStringUtils_isNotBlankWithNSString_(colorStr) {
            if colorStr.hasPrefix("#") {
                colorStr.removeAtIndex(colorStr.startIndex)
            }
            return UIColorFromRGB(strtoul(colorStr, nil, 16))
        } else {
            return UIColor.blackColor()
        }
    }

    // MARK: - Title and introduction

    func getButtonTitle() -> String {
        if mScripture!.useListView() {
            return getName()
        } else {
            let abbrev = getAbbrevName()
            return abbrev.isEmpty ? getName() : abbrev
        }
    }

    func getName() -> String {
        return mBook!.getName()
    }

    func getAbbrevName() -> String {
        return mBook!.getAbbrevName()
    }

    func hasIntroduction() -> Bool {
        return mBook!.hasIntroduction()
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

    // MARK: - Chapters

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
        var success = (number <= numberOfChapters()) && (number > lowThreshold)
        return success
    }

    func getBookGroup() -> String {
        return mBook!.getGroup()
    }

    func canGetNextChapter() -> Bool {
        if let chapter = getCurrentChapterNumber() {
            return canGetChapter(chapter + 1)
        } else {
            return false
        }
    }

    func canGetPreviousChapter() -> Bool {
        if let chapter = getCurrentChapterNumber() {
            return canGetChapter(chapter - 1)
        } else {
            return false
        }
    }
    func getFormattedBookChapter() -> String {
        var retString = getName()
        if (getCurrentChapterNumber() == 0) {
            retString = retString + " " + mScripture!.getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_TITLE_)
        } else {
            retString = retString + " " + String(getCurrentChapterNumber()!)
        }
        return retString
    }

    // MARK: - Misc

    func sameBook(book: ALSBook) -> Bool {
        return book.getBookId() == mBook?.getBookId()
    }

    private func runJavascript(jscript: String, webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString(jscript)
    }

}
