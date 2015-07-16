//
//  Misc.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/15/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation
import UIKit

var scripture: Scripture = {
    let scrip = Scripture()
    scrip.loadConfig()
    scrip.loadLibrary()
    return scrip
    }()

var config: ALSConfig = scripture.getConfig()

func updateGlobalUIFromConfig() {
    // color strings
        // taken from DefaultColors.java
    let colorNames = [
        "TextColor", "TitlesColor", "BackgroundColor", "VerseNumberColor", "FootnoteBackgroundColor", "PopupBackgroundColor", "TextHighlightColor",
        "LinkColor", "FooterBackgroundColor",
        "ChapterButtonColor", "ChapterButtonTextColor", "ChapterButtonIntroColor",
        "BookListDefaultColor", "BookButtonDefaultColor", "BookButtonTextColor",
        "SearchTextColor", "SearchButtonColor", "SearchButtonTextColor", "SearchProgressButtonColor", "SearchProgressButtonTextColor",
        "ActionBarTopColor", "ActionBarBottomColor",
        "AudioBarTopColor", "AudioBarBottomColor", "AudioBarTopLine1Color", "AudioBarTopLine2Color",
        "VerseBlock1Color", "VerseBlock2Color"
    ]
    let colorScheme = config.getColorScheme()
    let colors = [String: String]()
}