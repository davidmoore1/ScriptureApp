//
//  Book.swift
//  ScriptureApp
//
//  Created by David Moore on 7/2/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation

public class Book {
    var mBook: ALSBook?
    var mIndex: Int?
    var mGroup: Int?
    var mGroupIndex: Int?
    var mBookGroupString: String?
    
    public init (book: ALSBook?, index: Int?, group: Int?, groupIndex: Int?, groupString: String?) {
        mBook = book
        mIndex = index
        mGroup = group
        mGroupIndex = groupIndex
        mBookGroupString = groupString
    }
}