//
//  BookTableViewCell.swift
//  ScriptureApp
//
//  Created by David Moore on 7/2/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    var book: Book? {
        didSet {
            updateUI()
        }
    }
    @IBOutlet weak var mGroupLabel: UILabel!
    @IBOutlet weak var mBookLabel: UILabel!

    func updateUI() {
        if book?.mGroupIndex == 0 {
            mGroupLabel?.text = book?.mBookGroupString
        } else {
            mGroupLabel?.text = ""
        }
        mBookLabel?.text = book?.getName()
        contentView.backgroundColor = book?.getBackgroundColor()
    }
}
