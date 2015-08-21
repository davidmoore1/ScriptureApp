//
//  Scripture.swift
//  ScriptureApp
//
//  Created by David Moore on 6/11/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

public class Scripture {

    // MARK: - Properties and initialization

    private lazy var config = { sharedInstance.getConfig() }()
    private var mLibrary: ALSAppLibrary = ALSAppLibrary()
    private var mParser: ALSConfigParser?
    private var mWriter: ALSDisplayWriter?
    private var mScripture: IOSFactory = IOSFactory()
    private var mPopupHandler = AISPopupHandler()
    private var mBookArray: [[Book]]?
    private var mCurrentBook: Book?
    private var mFileManager: IOSFileManager = IOSFileManager()
    private var mColorThemes: [ALCColorTheme]?
    var mAssetsPath: String = ""
    var searchRange : String?
    var searchGroup : String
    var OTName : String = "Old Testament"
    var NTName : String = "New Testament"
    var firstBookIndex : Int = 0

    static let sharedInstance: Scripture = {
        let scripture = Scripture()
        scripture.loadConfig()
        scripture.loadLibrary()
        return scripture
    }()

    private init() {
        var assetsPath = ""
        searchGroup = ""
        var bundle = NSBundle.mainBundle()
        // using paths...
        if let bundlePath = bundle.resourcePath
        {
            assetsPath = bundlePath.stringByAppendingPathComponent("assets")
        }
        mScripture.setFileManagerWithAICFileManagerIOS(mFileManager)
        mFileManager.setAssetsPathWithNSString(assetsPath)
        mFileManager.setAppDefinitionWithALCAppDefinition(mLibrary)
        mScripture.setLibraryWithALSAppLibrary(mLibrary)
        mLibrary.getConfig().initConfig()
        mScripture.setAssetsPathWithNSString(assetsPath)
        mAssetsPath = assetsPath + "/"
    }

    func loadLibrary() {
        if (mLibrary.getBookCollections().size() > 0) {
            mLibrary.clear()
        }
         var success = false
        var glossaryBook: ALSBook? = nil;
        loadConfig()
        mFileManager.loadAbout()
        var book : ALSBook? = ALSFactoryCommon_getBookToShowFirstWithALSAppLibrary_withNSString_(mLibrary, "")
        (success, book) = loadBook(book)


        if (success) {
            mLibrary.getConfig().initFontSize()
        }

        mWriter = getDisplayWriter()
        mWriter!.setIllustrationFilenamesWithJavaUtilList(getFactory().getIllustrationFilenamesFromAssets())
        // Load glossary
        if (success) {
            glossaryBook = mLibrary.getMainBookCollection().getGlossaryBook()
            if (glossaryBook != nil) {
                (success, glossaryBook) = loadBook(glossaryBook)
                ALSFactoryCommon_parseGlossaryWithALSBook_withALSDisplayWriter_(glossaryBook, mWriter)
            }
        }
        AISPopupHandler_initWithALSAppLibrary_withALSDisplayWriter_withAISScriptureFactoryIOS_(mPopupHandler, mLibrary, mWriter, mScripture)
        mPopupHandler.initBookPopup()

        if (success && configHasFeature(ALCCommonFeatureName_SPLASH_SCREEN_)) {
            mScripture.prepareChaptersWithALSDisplayWriter(mWriter, withALSBook: book)
        }
        createBookArray()
        //searchRange = getString(ALSScriptureStringId_SEARCH_WHOLE_BIBLE_)
        searchRange = "Whole Bible"
    }

    func getLibrary() -> (ALSAppLibrary) {
        return mLibrary
    }

    func getDisplayWriter() -> ALSDisplayWriter {
        if (mWriter == nil) {
            mWriter = new_ALSDisplayWriter_initWithALSAppLibrary_withALSExportTypeEnum_(mLibrary, ALSExportTypeEnum_valueOfWithNSString_("APP"))
        }
        return mWriter!
    }

    func getFactory() -> AISScriptureFactoryIOS {
        return mScripture
    }

    // MARK: - Config

    func getConfig() -> ALSConfig {
        return mLibrary.getConfig()
    }

    func loadConfig() {
        var bundle = NSBundle.mainBundle()

        // using paths...
        if let bundlePath = bundle.resourcePath
        {
            var assetsPath = bundlePath + "/assets"
            let (contents, errOpts) = contentsOfDirectoryAtPath(assetsPath)
            let configFile = ALSFactoryCommon_getConfigFilenameWithJavaUtilList_(stringToUtilList(contents!))
            var isEncrypted = ALCFileManagerCommon_isEncryptedFileWithNSString_(configFile)
            var fullFilePath = assetsPath + "/" + configFile
            var sb = mScripture.loadExternalFileToStringBuilderWithNSString(fullFilePath, withBoolean: isEncrypted)
            var xmlString = sb.description()
            var ioStream = xmlString.getBytesWithCharsetName("UTF-8")
            var sbInputStream = new_JavaIoByteArrayInputStream_initWithByteArray_(ioStream)
            mParser = ALSConfigParser()
            mParser!.setLibraryWithALSAppLibrary(mLibrary)
            mParser!.setInputStreamWithJavaIoInputStream(sbInputStream)
            mParser!.parse()
            ALSFactoryCommon_setMappingsWithALSAppLibrary_(mLibrary)
        }
    }

    func configHasFeature(feature: String) -> Bool {
        return mLibrary.getConfig().hasFeatureWithNSString(feature)
    }

    func configGetFeature(feature: String) -> String {
        return mLibrary.getConfig().getFeatures().getValueWithNSString(feature)
    }

    func configGetBoolFeature(feature: String) -> Bool {
        var retVal = true
        if (configGetFeature(feature) == "false") {
            retVal = false
        }
        return retVal
    }

    // MARK: - Book

    func loadBook(book: Book?) -> (success: Bool, book: Book?) {
        var success = false
        var lBook = book;
        if (lBook != nil) {
            var results = loadBook(lBook!.getALSBook())
            success = results.success
        }
        return (success, lBook)
    }

    func loadBook(book: ALSBook?) -> (success: Bool, book: ALSBook?) {
        var success = mScripture.loadBookWithALSBook(book)
        return (success, book)
    }

    func updateCurrentBook(book: Book?) {
        mCurrentBook = book
        mScripture.updateCurrentBookWithALSBook(book!.getALSBook())
    }

    private func getALSBookFromCollection(bookIndex: Int) -> ALSBook? {
        let jintIndex = Int32(bookIndex)
        let retBook  = mLibrary.getMainBookCollection().getBooks().getWithInt(jintIndex) as! ALSBook
        return retBook
    }

    func getCurrentBook() -> Book? {
        return mCurrentBook
    }

    func getBook(index: Int) -> Book? {
        for (var i = 0; i < mBookArray!.count; i++){
            for (var j=0; j < mBookArray![i].count; i++) {
                if mBookArray![i][j].mIndex == index {
                    return mBookArray![i][j]
                }
            }
        }
        return nil
    }

    func createBookArray() {
        var groupIndex = 0
        var currentGroupString = ""
        var groupNumber = 0
        var startBookID = getConfig().getStartBookId() ?? ""
        if (mBookArray == nil) {
            mBookArray = [[Book]]()
        }
        else {
            mBookArray!.removeAll()
        }
        var bookArray = [Book]()
        for (var i=0; i < numberOfBooks; i++) {
            let book = getALSBookFromCollection(i)
            let bookGroupString = getBookGroupString(book!, firstBook: (i == 0))
            if bookGroupString.newGroup {
                if bookArray.count > 0 {
                    mBookArray!.append(bookArray)
                    groupNumber++
                    groupIndex = 0
                    bookArray.removeAll()
                }
                currentGroupString = bookGroupString.bookGroupString
                if (book!.getGroup() == "OT") {
                    OTName = currentGroupString
                } else if (book!.getGroup() == "NT") {
                    NTName = currentGroupString
                }
            }
            let bookForArray = Book(scripture: self, book: book, index: i, group: groupNumber, groupIndex: groupIndex, groupString: currentGroupString)
            if (!startBookID.isEmpty && (book?.getBookId() == startBookID)) {
                firstBookIndex = i
            }
            groupIndex++
            bookArray.append(bookForArray)
        }
        if (bookArray.count > 0) {
            mBookArray!.append(bookArray)
        }

    }

    func getBookArray() -> [[Book]] {
        if (mBookArray == nil) {
            createBookArray()
        }
        return mBookArray!
    }

    func clearBookArray() {
        if (mBookArray != nil) {
            mBookArray!.removeAll()
        }
        mBookArray = nil
    }

    func findBookInArray(book: ALSBook) -> Book? {
        var bookArray: [[Book]] = getBookArray()
        for (var i = 0; i < bookArray.count; i++){
            for (var j=0; j < bookArray[i].count; j++) {
                if bookArray[i][j].sameBook(book) {
                    return bookArray[i][j]
                }
            }
        }
        return nil
    }

    func findBookFromResult(result: ALSSearchResult) -> Book? {
        var reference = result.getReference()
        var retBook: Book? = nil
        if let alsBook = mLibrary.getMainBookCollection().getBookWithNSString(reference.getBookId()) {
            retBook = findBookInArray(alsBook)
        }
        return retBook
    }

    var numberOfBooks: Int {
        get {
            return Int(mLibrary.getMainBookCollection().getBooks().size())
        }
    }

    func getBookGroupString(book: ALSBook, firstBook: Bool) -> (newGroup: Bool, bookGroupString: String) {
        var success = false
        if (firstBook) {
            // Reset the current group if this is the initial call for this pass
            mPopupHandler.setCurrentBookGroupWithNSString("")
        }
        var showBookGroupTitles = configHasFeature(ALSScriptureFeatureName_BOOK_GROUP_TITLES_)
        var retString = mPopupHandler.getBookGroupStringWithALSBook(book, withBoolean: showBookGroupTitles)
        if (retString != "") {
            success = true
        }
        return (success, retString)
    }
    
    func getCurrentChapter() -> ALSChapter {
        return mLibrary.getCurrentChapter()
    }

    func getIntroductionTitle() -> String {
        return getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_TITLE_)
    }

    func getIntroductionSymbol() -> String {
        return getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_SYMBOL_)
    }

    // MARK: - Color theme and font size

    func getAvailableColorThemeNames() -> [String] {
        return getConfig().getAvailableColorThemes().map { ($0 as! ALCColorTheme).getName() }
    }

    func getStyleNames() -> [String] {
        return getConfig().getStyles().map { ($0 as! ALCStyle).getName() }
    }
    
    func getBarBackgroundColor() -> UIColor {
        let topColor = getActionBarTopColor()
        let bottomColor = getActionBarBottomColor()
        return getMidColor(topColor, bottomColor)
    }

    func getActionBarTopColor() -> UIColor {
        return UIColorFromRGB(getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_UI_ACTION_BAR_, withNSString: ALCPropertyName_COLOR_TOP_))
    }

    func getActionBarBottomColor() -> UIColor {
        return UIColorFromRGB(getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_UI_ACTION_BAR_, withNSString: ALCPropertyName_COLOR_BOTTOM_))
    }

    func getPopupBackgroundColor() -> UIColor {
        var colorStr = getConfig().getColorDefs().getColorStringFromNameWithNSString("PopupBackgroundColor", withNSString: getConfig().getCurrentColorTheme())
        if colorStr.hasPrefix("#") {
            colorStr.removeAtIndex(colorStr.startIndex)
        }
        return UIColorFromRGB(strtoul(colorStr, nil, 16))
    }

    func getViewerBackgroundColor() -> UIColor {
        return UIColorFromRGB(config.getViewerBackgroundColor())
    }

    func getColorStringFromStyle(styleName: String) -> String {
        return config.getStylePropertyColorValueWithNSString(styleName, withNSString: ALCPropertyName_COLOR_)
    }

    func getColorFromStyle(styleName: String) -> UIColor {
        return UIColorFromRGB(getColorStringFromStyle(styleName))
    }

    func getBackgroundColorStringFromStyle(styleName: String) -> String {
        return config.getStylePropertyColorValueWithNSString(styleName, withNSString: ALCPropertyName_BACKGROUND_COLOR_)
    }

    func getBackgroundColorFromStyle(styleName: String) -> UIColor {
        return UIColorFromRGB(getBackgroundColorStringFromStyle(styleName))
    }

    func getBookGroupTitleColor() -> UIColor {
        return getColorFromStyle(ALSStyleName_UI_BOOK_GROUP_TITLE_)
    }

    func getChapterButtonColor() -> UIColor {
        return getColorFromStyle(ALSStyleName_UI_CHAPTER_BUTTON_)
    }

    func getChapterButtonBackgroundColor() -> UIColor {
        return getBackgroundColorFromStyle(ALSStyleName_UI_CHAPTER_BUTTON_)
    }

    func getIntroductionButtonBackgroundColor() -> UIColor {
        return getBackgroundColorFromStyle(ALSStyleName_UI_CHAPTER_INTRO_BUTTON_)
    }

    func getThemeSelectorButtonBackgroundColorForTheme(theme: String) -> UIColor {
        return UIColorFromRGB(config.getStylePropertyColorValueWithNSString("ui.background", withNSString: ALCPropertyName_BACKGROUND_COLOR_, withNSString: theme))
    }

    func getFootnoteBackgroundColor() -> UIColor {
        return getBackgroundColorFromStyle("body.footnote")
    }

    func getSearchInfoPanelColor() -> UIColor {
        return getColorFromStyle(ALSStyleName_SEARCH_INFO_PANEL_)
    }

    func getSearchCheckboxLabelColor() -> UIColor {
        return getColorFromStyle(ALSStyleName_SEARCH_CHECKBOX_)
    }

    func getSearchEntryTextColor() -> UIColor {
        return getColorFromStyle(ALSStyleName_SEARCH_ENTRY_TEXT_)
    }

    func getSearchButtonBackgroundColor() -> UIColor {
        return getBackgroundColorFromStyle(ALSStyleName_SEARCH_BUTTON_)
    }

    func getSearchButtonColor() -> UIColor {
        return getColorFromStyle(ALSStyleName_SEARCH_BUTTON_)
    }

    // MARK: - Navigation and annotations

    func goToReference(book: Book?, chapterNumber: Int, webView: UIWebView) -> Bool {
        var success: Bool = false
        if (book != nil) {
            mScripture.loadBookIfNotAlreadyWithALSBook(book!.getALSBook())
            updateCurrentBook(book)
            var url: NSURL = NSURL(string: mAssetsPath)!
            if (book!.hasIntroduction() && chapterNumber == 0) {
                var result = book!.getIntroduction()
                success = result.success
                if (result.success) {
                    webView.loadHTMLString(result.chapter, baseURL: url)
                }
            } else if (chapterNumber > 0) {
                var result = book!.getChapter(chapterNumber)
                success = result.success
                var test = result.chapter
                if (result.success) {
                    webView.loadHTMLString(result.chapter, baseURL: url)
                }
            }
        }
        return success
    }

    func goToVerse(verseNumber: String, webView: UIWebView) -> String? {
        var javaString = "document.getElementById('" + verseNumber + "').scrollIntoView(true);"
        let result = webView.stringByEvaluatingJavaScriptFromString(javaString)
        return result
    }

    func getHtmlForAnnotation(url: String, links: ALSLinks) -> (results: AISPopupHandlerResult, popupLinks: ALSLinks?) {
        var retLinks = ALSLinks()
        var results = mPopupHandler.shouldOverrideUrlLoadingWithNSString(url, withALSLinks: links, withALSLinks: retLinks)
        return (results, retLinks)
    }

    func highlightVerse(verseNumber: String, webView: UIWebView) -> String? {
        var backColor = mLibrary.getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_TEXT_HIGHLIGHTING_, withNSString: ALCPropertyName_BACKGROUND_COLOR_)
        var javaString = "(function colorElement(id) { "
        javaString += "var i = 0; "
        // Get first matching element
        javaString += "var el = document.getElementById(id); " +

            // If not found, try with 'a' after it
            "if (!el) {" +
            "  el = document.getElementById(id + 'a'); " +
            "}" +

            // For each matching element, change background color.
            "while (el) {" +
            "  el.style.backgroundColor = '" + backColor + "';" +
            "  i++;" +
            "  el = document.getElementById(id + '+' + i); " +
            "}" +

            " })('" + verseNumber + "')"
        let result = webView.stringByEvaluatingJavaScriptFromString(javaString)
        return result
    }

    func fadeElement(verseNumber: String, webView: UIWebView) -> String? {
        var backColor = mLibrary.getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_TEXT_HIGHLIGHTING_, withNSString: ALCPropertyName_BACKGROUND_COLOR_)
        var toColor = mLibrary.getConfig().getViewerBackgroundColor()
        var rgbFrom = ALCColorUtils_hexColorToRgbArrayWithNSString_(backColor)
        var rgbTo = ALCColorUtils_hexColorToRgbArrayWithNSString_(toColor)
        var finalColor = ""
        var javaString = "(function fadeElement(id) { " +
            "var i = 0; " +

                // Get first matching element
                "var el = document.getElementById(id); " +

                // If not found, try with 'a' after it
                "if (!el) {" +
                "  el = document.getElementById(id + 'a'); " +
                "}"

                // For each matching element, fade background color.
       javaString = javaString + "while (el) {" +
                "  fade(el, " + rgbFrom + ", " + rgbTo + ", '" + finalColor + "', 3000);" +
                "  i++;" +
                "  el = document.getElementById(id + '+' + i); " +
                "}" +

                " })('" + verseNumber + "')"
        let result = webView.stringByEvaluatingJavaScriptFromString(javaString)
        return result
    }

    // MARK: - Strings

    func getSearchCancelButtonTitle() -> String {
        return getString(ALSScriptureStringId_SEARCH_CANCEL_BUTTON_)
    }

    func getAboutTitle() -> String {
        return getString(ALSScriptureStringId_MENU_ABOUT_)
    }

    func getCloseButtonTitle() -> String {
        return getString(ALCCommonStringId_BUTTON_CLOSE_)
    }

    func getSearchWholeBibleTitle() -> String {
//        return getString(ALSScriptureStringId_SEARCH_WHOLE_BIBLE_)
        return "Whole Bible"
    }

    func getSearchButtonTitle() -> String {
        return getString(ALSScriptureStringId_SEARCH_BUTTON_)
    }

    func getMatchWholeWordsTitle() -> String {
        return getString(ALSScriptureStringId_SEARCH_MATCH_WHOLE_WORDS_)
    }

    func getSearchHint() -> String {
        return getString(ALSScriptureStringId_SEARCH_TEXT_HINT_)
    }

    func getMatchAccentsTitle() -> String {
        return getString(ALSScriptureStringId_SEARCH_MATCH_ACCENTS_)
    }

    func getNoMatchesFoundString() -> String {
        return getString(ALSScriptureStringId_SEARCH_NO_MATCHES_FOUND_)
    }

    // MARK: - Feature flags

    func useListView() -> Bool {
        var bookSelectOption = configGetFeature(ALSScriptureFeatureName_BOOK_SELECTION_)
        var isList = ALCStringUtils_isNotBlankWithNSString_(bookSelectOption) ? bookSelectOption.lowercaseString == "list" : true
        return isList
    }

    func hasFeatureSearch() -> Bool {
        return configGetBoolFeature(ALCCommonFeatureName_SEARCH_)
    }

    func hasFeatureSectionTitles() -> Bool {
        return config.hasFeatureWithNSString(ALSScriptureFeatureName_BOOK_GROUP_TITLES_)
    }

    func hasMatchAccentsDefault() -> Bool {
        return configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_DEFAULT_)
    }

    func hasMatchWholeWordsDefault() -> Bool {
        return configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_DEFAULT_)
    }

    func hasMatchAccents() -> Bool {
        return configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_SHOW_)
    }

    func hasMatchWholeWords() -> Bool {
        return configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_SHOW_)
    }


    // MARK: - Misc

    func getString(id : String) -> String {
        return ALSFactoryCommon_getStringWithNSString_(id)
    }

    func getAboutHtml() -> String {
        var aboutText = mLibrary.getAbout().getText()
        var html = mWriter!.getHtmlForAboutBoxWithNSString(aboutText)
        return html
    }

    func getSpecialCharacters() -> [[String]] {
        return getConfig().getInputButtonLines().map {
            let row = $0 as! ALCInputButtonRow
            let buttons = (row.getButtons() as! JavaUtilAbstractList).map { $0 as! ALCInputButton }
            let forms = buttons.map { $0.getDisplayForm() }
            let strings = forms.map { ALCStringUtils_convertCharCodesToStringWithNSString_($0)! }
            return strings
        }
    }

    func loadExpiryMessage() {
        mFileManager.loadExpiryMessage()
    }

    func hasExpired() -> Bool {
        let expiry = config.getExpiry()

        if expiry.canExpire() {
            let prefs = NSUserDefaults.standardUserDefaults()
            let sdf = JavaTextSimpleDateFormat(NSString: "yyyy-MM-dd")
            let startDate = JavaUtilCalendar.getInstance()
            startDate.setWithInt(JavaUtilCalendar_HOUR, withInt: 0)
            if let savedStartDate = prefs.stringForKey(Constants.StartDateKey) {
                startDate.setTimeWithJavaUtilDate(sdf.parseWithNSString(savedStartDate))
            } else {
                let savedStartDate = sdf.formatWithJavaUtilDate(startDate.getTime())
                prefs.setObject(savedStartDate, forKey: Constants.StartDateKey)
            }

            let todayDate = JavaUtilCalendar.getInstance()
            todayDate.setWithInt(JavaUtilCalendar_HOUR, withInt: 0)

            return expiry.hasExpiredWithJavaUtilCalendar(startDate, withJavaUtilCalendar: todayDate)
        } else {
            return false
        }
    }

}