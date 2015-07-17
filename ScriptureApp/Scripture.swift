//
//  Scripture.swift
//  ScriptureApp
//
//  Created by David Moore on 6/11/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

public class Scripture {
    private var mLibrary: ALSAppLibrary = ALSAppLibrary()
    private var mParser: ALSConfigParser?
    private var mWriter: ALSDisplayWriter?
    private var mScripture: IOSFactory = IOSFactory()
    private var mPopupHandler = AISPopupHandler()
    private var mBookArray: [[Book]]?
    private var mCurrentBook: Book?
    private var mFileManager: IOSFileManager = IOSFileManager()
    
    init() {
        var assetsPath = ""
        var bundle = NSBundle.mainBundle()
        // using paths...
        if let bundlePath = bundle.resourcePath
        {
            assetsPath = bundlePath + "/assets"
        }
        mScripture.setFileManagerWithAICFileManagerIOS(mFileManager)
        mFileManager.setAssetsPathWithNSString(assetsPath)
        mFileManager.setAppDefinitionWithALCAppDefinition(mLibrary)
        mScripture.setLibraryWithALSAppLibrary(mLibrary)
        mLibrary.getConfig().initConfig()
        mScripture.setAssetsPathWithNSString(assetsPath)
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
        
        // Load glossary
        if (success) {
            glossaryBook = mLibrary.getMainBookCollection().getGlossaryBook()
            if (glossaryBook != nil) {
                (success, glossaryBook) = loadBook(glossaryBook)
            }
        }
        
        if (success) {
            mLibrary.getConfig().initFontSize()
        }

        mWriter = getDisplayWriter()
        AISPopupHandler_initWithALSAppLibrary_withALSDisplayWriter_withAISScriptureFactoryIOS_(mPopupHandler, mLibrary, mWriter, mScripture)
        mPopupHandler.initBookPopup()

        if (success && mLibrary.getConfig().hasFeatureWithNSString(ALCCommonFeatureName_SPLASH_SCREEN_)) {
            ALSFactoryCommon_parseGlossaryWithALSBook_withALSDisplayWriter_(glossaryBook, mWriter)
            mScripture.prepareChaptersWithALSDisplayWriter(mWriter, withALSBook: book)
        }
        createBookArray()
    }

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
    func getLibrary() -> (ALSAppLibrary) {
        return mLibrary
    }
    func getDisplayWriter() -> ALSDisplayWriter {
        if (mWriter == nil) {
            mWriter = new_ALSDisplayWriter_initWithALSAppLibrary_(mLibrary)
        }
        return mWriter!
    }
    func getConfig() -> ALSConfig {
        return mLibrary.getConfig()
    }
    func getFactory() -> AISScriptureFactoryIOS {
        return mScripture
    }
    func getHtml(text: String) -> String {
        var retString = ""
        var htmlLinks = ALSLinks()
        ALSLinks_init(htmlLinks)
        retString = mWriter!.getHtmlForFootnoteWithNSString(text, withALSLinks: htmlLinks)
        return retString
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
    
    // Get contents of directory at specified path, returning (filenames, nil) or (nil, error)
    func contentsOfDirectoryAtPath(path: String) -> (filenames: [String]?, error: NSError?) {
        var error: NSError? = nil
        let fileManager = NSFileManager.defaultManager()
        let contents = fileManager.contentsOfDirectoryAtPath(path, error: &error)
        if contents == nil {
            return (nil, error)
        }
        else {
            let filenames = contents as! [String]
            return (filenames, nil)
        }
    }
    
    func createBookArray() {
        var groupIndex = 0
        var currentGroupString = ""
        var groupNumber = 0
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
            }
            let bookForArray = Book(scripture: self, book: book, index: i, group: groupNumber, groupIndex: groupIndex, groupString: currentGroupString)
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
    func getHtmlForAnnotation(url: String) -> String {
        var html = mPopupHandler.shouldOverrideUrlLoadingWithNSString(url)
        return html
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
    
    func configHasFeature(feature: String) -> Bool {
        return mLibrary.getConfig().hasFeatureWithNSString(feature)
    }
    
    func goToReference(book: Book?, chapterNumber: Int, webView: UIWebView) -> Bool {
        var success: Bool = false
        if (book != nil) {
            mScripture.loadBookIfNotAlreadyWithALSBook(book!.getALSBook())
            updateCurrentBook(book)
            if (book!.hasIntroduction() && chapterNumber == 0) {
                var result = book!.getIntroduction()
                success = result.success
                if (result.success) {
                    webView.loadHTMLString(result.chapter, baseURL: nil)
                }
            } else if (chapterNumber > 0) {
                var result = book!.getChapter(chapterNumber)
                success = result.success
                if (result.success) {
                    webView.loadHTMLString(result.chapter, baseURL: nil)
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
    func popup(webView: UIWebView) -> String? {
        var javaString = "window.alert('Hello there');"
        let result = webView.stringByEvaluatingJavaScriptFromString(javaString)
        return result
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
    func useListView() -> Bool {
        var bookSelectOption = mLibrary.getConfig().getFeatures().getValueWithNSString(ALSScriptureFeatureName_BOOK_SELECTION_)
        var isList = ALCStringUtils_isNotBlankWithNSString_(bookSelectOption)
        return isList
    }
    
    func getAboutHtml() -> String {
        var aboutText = mLibrary.getAbout().getText()
        var html = mWriter!.getHtmlForAboutBoxWithNSString(aboutText)
        return html
    }
    func getString(id : String) -> String {
        return ALSFactoryCommon_getStringWithNSString_(id)
    }
    
    func stringToUtilList(strings: [String]) -> (JavaUtilList) {
        let utilList = new_JavaUtilArrayList_init()
        for entry in strings {
            utilList.addWithId(entry)
        }
        return utilList
    }
    
    func utilListToStringArray(javaArray: JavaUtilList) -> [String] {
        var stringArray = [String]()
        var iterator = javaArray.iterator()
        while (iterator.hasNext()) {
            var object: AnyObject! = iterator.next()
            stringArray.append(object as! String)
        }
        return stringArray
    }
    
    
}