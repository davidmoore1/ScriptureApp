//
//  SearchTableViewCell.swift
//  ScriptureApp
//
//  Created by David Moore on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell, UITextViewDelegate {
    let config = Scripture.sharedInstance.getConfig()
    var reference: String?
    var html: NSAttributedString? {
        didSet {
            updateUI()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.htmlTextField.delegate = self;
    }

    @IBOutlet weak var htmlTextField: UITextView!
    @IBOutlet weak var referenceLabel: UILabel!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI() {
        referenceLabel.text = reference!
        referenceLabel.textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_INFO_PANEL_, withNSString: ALCPropertyName_COLOR_))
        backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        htmlTextField.backgroundColor = backgroundColor
        htmlTextField.attributedText = html
        htmlTextField.sizeToFit()
        htmlTextField.layoutIfNeeded()
     }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
}
