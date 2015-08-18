//
//  SearchInfo.swift
//  ScriptureApp
//
//  Created by David Moore on 8/17/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation

public class SearchInfo {
    private var mSearchString : String?
    private var mMatchWholeWord : Bool?
    private var mMatchAccents : Bool?
    private var mBooksAdded: Int = 0
    private var mResultCount: Int = 0
    var mSearchResults = [[AISSearchResultIOS]]()
    var selectedIndexPath: NSIndexPath?

    static let sharedInstance: SearchInfo = {
        let searchInfo = SearchInfo()
        searchInfo.reset()
        return searchInfo
    }()
    
    func reset() {
        mSearchString = ""
        mMatchWholeWord = true
        mMatchAccents = true
        mSearchResults = [[AISSearchResultIOS]]()
        mBooksAdded = 0
        mResultCount = 0
        searchComplete = false
        selectedIndexPath = nil
    }
    var searchComplete: Bool = false
    var booksAdded: Int {
        get {
            return mBooksAdded
        }
        set {
            mBooksAdded = newValue
        }
    }
    func incrementBooksAdded() {
        mBooksAdded++
    }
    var resultCount: Int {
        get {
            return mResultCount
        }
        set {
            mResultCount = newValue
        }
    }
    func incrementResultCount() {
        mResultCount++
    }

    var matchWholeWords: Bool {
        get {
            return mMatchWholeWord!
        }
        set {
            mMatchWholeWord = newValue
        }
    }

    var matchAccents: Bool {
        get {
            return mMatchAccents!
        }
        set {
            mMatchAccents = newValue
        }
    }
    
    var searchString: String {
        get {
            return mSearchString!
        }
        set {
            mSearchString = newValue
        }
    }


}