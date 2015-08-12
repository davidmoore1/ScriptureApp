//
//  Constants.swift
//  ScriptureApp
//
//  Created by David Moore on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation

public struct Constants {
    static let SearchRequest = "SearchRequest"
    static let AnnotationSeque = "Annotation"
    static let ImageAnnotationSegue = "ImageAnnotationSegue"
    static let ShowChaptersSeque = "ShowChapters"
    static let DisplayChapterSeque = "DisplayChapter"
    static let SearchResultsSeque = "SearchResults"
    static let SelectBookSeque = "SelectBook"
    static let SearchGoToVerseSeque = "SearchGoToVerse"
    static let SearchRangeSeque = "SearchRange"
    static let BookReuseIdentifier = "Book"
    static let VerseCellReuseIdentifier = "Verse"
    static let SearchCellReuseIdentifier = "Search"
    static let SearchRangeCellReuseIdentifier = "SearchRangeID"
    static let AboutSeque = "about"
    static let TextSizeSeque = "text size"
    static let SelectBook = "selectBook"
    static let SelectChapter = "selectChapter"
    static let StartDateKey = "start-date"
    static let BookNumberKey = "book-number"
    static let ChapterNumberKey = "chapter-number"

    static let SelectSearchResult = "SelectSearchResult"
    static let SpecialCharacterCell = "SpecialCharacterCell"

    static let UpArrow = "▴"
    static let DownArrow = "▾"
    static let Arrow = BarOnTop ? DownArrow : UpArrow

    static let BarOnTop = true
    static let UseGradient = false
    static let GradientName = "gradientName"

    static let MaxResults = 5000
}
