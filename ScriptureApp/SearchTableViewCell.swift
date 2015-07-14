//
//  SearchTableViewCell.swift
//  ScriptureApp
//
//  Created by David Moore on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    var reference: String?
    var searchResult: ALSSearchResult?
    var html: String? {
        didSet {
            updateUI()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var cellWebView: UIWebView!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI() {
        referenceLabel.text = reference!
        cellWebView.loadHTMLString(html, baseURL: nil)
     }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
