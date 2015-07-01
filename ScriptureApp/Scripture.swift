//
//  Scripture.swift
//  ScriptureApp
//
//  Created by David Moore on 6/11/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import Foundation

class Scripture {
    private var mLibrary: ALSAppLibrary = ALSAppLibrary()
    private var mParser: ALSConfigParser?
    private var mAppConfig: ALCAppConfig
    private var mWriter: ALSDisplayWriter?
    private var mScripture: AISScriptureFactoryIOS = AISScriptureFactoryIOS()
    private var mLastChapterRequested: Int?
    private var mPopupHandler = AISPopupHandler()
    var mCurrentBookGroup: String
    
    init() {
        mCurrentBookGroup = ""
        mAppConfig = ALCAppConfig();
        mAppConfig.initConfig()
        var bundle = NSBundle.mainBundle()
        // using paths...
        if let bundlePath = bundle.resourcePath
        {
            mScripture.setAssetsPathWithNSString(bundlePath + "/assets")
        }
    }
    
    func loadLibrary() {
        if (mLibrary.getBookCollections().size() > 0) {
            mLibrary.clear()
        }
        var success = false
        var glossaryBook: ALSBook? = nil;
        loadConfig()
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
        AISPopupHandler_initWithALSAppLibrary_withALSDisplayWriter_(mPopupHandler, mLibrary, mWriter)

//        if (success && mLibrary.getConfig().hasFeatureWithNSString(ALCCommonFeatureName_SPLASH_SCREEN_)) {
            ALSFactoryCommon_parseGlossaryWithALSBook_withALSDisplayWriter_(glossaryBook, mWriter)
            AISScriptureFactoryIOS_prepareChaptersWithALSDisplayWriter_withALSBook_withALSAppLibrary_(mWriter, book, mLibrary)
//            mScripture.prepareChaptersWithALSDisplayWriter(mWriter, withALSBook: book, withALSAppLibrary: mLibrary)
//        }
    }
    
    func loadBook(book: ALSBook?) -> (success: Bool, book: ALSBook?) {
        var success = false

        var lBook = book;
        if (lBook != nil)    {
            var bundle = NSBundle.mainBundle()
            // using paths...
            if let bundlePath = bundle.resourcePath
            {
                success = mScripture.loadBookFromAssetsFileWithALSBook(lBook!,  withALSAppLibrary: mLibrary)
                mLibrary.setCurrentBookWithALSBook(lBook)
            }
            
        }
        return (success, lBook)
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
            let factory = IOSFactory()
            var fullFilePath = assetsPath + "/" + configFile
            var sb = factory.loadExternalFileToStringBuilderWithNSString(fullFilePath, withBoolean: isEncrypted)
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
    
    func getHtmlForAnnotation(url: String) -> String {
        var html = mPopupHandler.shouldOverrideUrlLoadingWithNSString(url)
        return html
    }

    func numberOfChaptersInBook(book: ALSBook?) -> Int {
        // if config has feature hide empty chapters
        var retVal = -1
        if (book != nil) {
            retVal = Int(book!.getChapters().size())
        }
        return retVal
    }
    var numberOfBooks: Int {
        get {
            return Int(mLibrary.getMainBookCollection().getBooks().size())
        }
    }
    
    func getBook(bookIndex: Int) -> ALSBook? {
        let jintIndex = Int32(bookIndex)
        let retBook  = mLibrary.getMainBookCollection().getBooks().getWithInt(jintIndex) as! ALSBook
        return retBook
    }
    
    func getCurrentBook() -> ALSBook? {
        return mLibrary.getCurrentBook()
    }
    
    func getChapter(chapterNumber: Int) -> (success: Bool, chapter: String?) {
        var success = false
        var chapterString : String? = nil
        if ((chapterNumber <= numberOfChaptersInBook(mLibrary.getCurrentBook())) && (chapterNumber > 0)) {
            mLastChapterRequested = chapterNumber
            var iChapterNumber:CInt = CInt(chapterNumber)
            chapterString = AISScriptureFactoryIOS_getChapterWithALSDisplayWriter_withALSBook_withALSAppLibrary_withInt_(mWriter, mLibrary.getCurrentBook(), mLibrary, iChapterNumber)
            success = true
        }
        return (success, chapterString)
    }
    
    func getFormattedBookChapter() -> String {
        var bookName = getCurrentBook()?.getName()
        return bookName! + " " + String(mLastChapterRequested!)
        
    }
    func getCurrentChapterNumber() -> Int? {
        return mLastChapterRequested
    }
   
    func getNextChapter() -> (success: Bool, chapter: String?) {
        var nextChapterNumber = mLastChapterRequested! + 1
        return getChapter(nextChapterNumber)
    }

    func getPreviousChapter() -> (success: Bool, chapter: String?) {
        var previousChapterNumber = mLastChapterRequested! - 1
        return getChapter(previousChapterNumber)
    }
/*
    func getBookGroupString(book: ALSBook, Bool firstBook) -> (useString: Bool, bookGroupString: String) {
        if (firstBook) {
            mPopupHandler.
        }
        
    }*/
    func getDisplayWriter() -> ALSDisplayWriter {
        var writer: ALSDisplayWriter = new_ALSDisplayWriter_initWithALSAppLibrary_(mLibrary)
        return writer
    }
    
    func configHasFeature(feature: String) -> Bool {
        return mLibrary.getConfig().hasFeatureWithNSString(feature)
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