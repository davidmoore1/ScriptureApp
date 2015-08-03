//
//  SearchResultsViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 7/29/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var searchHandler = AISSearchHandler()
    var mSearchString : String?
    var mMatchWholeWord : Bool?
    var mMatchAccents : Bool?
    var mSearchResults = [[AISSearchResultIOS]]()
    var mStrings = Dictionary<NSIndexPath, NSAttributedString>()
    var mTitles = [NSString]()
    var mStopSearch = false
    var mClosing = false
    var mBook: ALSBook?
    var mBooksAdded: Int = 0
    var mScriptureController: ScriptureViewController?
    var mNumberOfBooks = 0
    private var mSelectedIndex: NSIndexPath?
    let mScripture = Scripture.sharedInstance
    let config = Scripture.sharedInstance.getConfig()
    var mBackGroundColorForHeader: UIColor?
    var mTextColorForHeader: UIColor?
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        mStopSearch = true
        mClosing = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
        // presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mNumberOfBooks = Int(mScripture.getLibrary().getMainBookCollection().getBooks().size())
        for (var i = 0; i < mNumberOfBooks; i++) {
            var book = mScripture.getBookArray().flatMap { $0 }[i]
            var abbrev = book.getAbbrevName()
            if ((i == 0) && (count(abbrev) < 4)) {
                // The first title sets the width of the index bar
                for (var j = count(abbrev); j < 4 ; j++) {
                    abbrev = abbrev + "  "
                }
            }
            mTitles.append(abbrev)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navBar.title = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        activityIndicator.startAnimating()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            self.searchTableView.estimatedRowHeight = 135
            self.searchTableView.rowHeight = UITableViewAutomaticDimension
        }
        var textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_COLOR_))
        var backgroundColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        self.searchTableView.sectionIndexColor = textColor
        self.searchTableView.sectionIndexBackgroundColor = backgroundColor
        view.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        mTextColorForHeader = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_BUTTON_, withNSString: ALCPropertyName_COLOR_))
        mBackGroundColorForHeader = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        self.activityIndicator.color = mTextColorForHeader
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.search()
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        mStopSearch = true
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return mNumberOfBooks
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]  {
        return mTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,  atIndex index: Int) -> Int {
        var retValue = index
        if (index > mBooksAdded - 1) && (index > 0) {
            retValue = mBooksAdded - 1
        }
        return retValue
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if (section > mSearchResults.count - 1) {
            return 0
        }
        return mSearchResults[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerString = ""
        if section <= mSearchResults.count - 1 {
            if mSearchResults[section].count > 0 {
                headerString = mSearchResults[section][0].getBookName()
            }
        }
        return headerString
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = mBackGroundColorForHeader
        header.textLabel.textColor = mTextColorForHeader
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SearchCellReuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
        
        // Configure the cell...
        var result = mSearchResults[indexPath.section][indexPath.row]
        if ((indexPath.section == 0) && (indexPath.row == 0) && (result.numberOfMatchesInReference() == 0)) {
            var emptyString = NSMutableAttributedString(string: "")
            cell.reference = mScripture.getString(ALSScriptureStringId_SEARCH_NO_MATCHES_FOUND_)
            cell.html = emptyString
            return cell
        }
        cell.reference = searchHandler.getReferenceTitleWithALSReference(result.getReference())
        cell.html = getAttributedTextString(indexPath)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mStopSearch = true
        mSelectedIndex = indexPath
        var selectedResult = mSearchResults[indexPath.section][indexPath.row]
        if ((indexPath.section == 0) && (indexPath.row == 0) && ( selectedResult.numberOfMatchesInReference() == 0 )) {
            // User selected "No results found
            return
        }
        mScriptureController!.mVerseNumber = String(selectedResult.getReference().getFromVerse())
        mScriptureController!.bookNumber = mScripture.findBookFromResult(selectedResult)!.mIndex!
        mScriptureController!.chapterNumber = Int(selectedResult.getReference().getChapterNumber())
        performSegueWithIdentifier(Constants.SelectSearchResult, sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            return UITableViewAutomaticDimension
        } else {
            var calculationView = UITextView()
            calculationView.attributedText = getAttributedTextString(indexPath)
            var size = calculationView.sizeThatFits(CGSizeMake(searchTableView.frame.width - 30, CGFloat(FLT_MAX)))
            var height = size.height + 21 + 24
            return height
        }
    }
    
    func getAttributedTextString(indexPath: NSIndexPath) -> NSAttributedString {
        var returnString = NSAttributedString(string: "")
        if let returnString = mStrings[indexPath] {
            return returnString
        } else {
            var attributedString = NSMutableAttributedString(string: "")
            var result = mSearchResults[indexPath.section][indexPath.row]
            if let context = result.getContext() {
                var nsContext = context as NSString
                let font = UIFont.systemFontOfSize(17.0)
                let boldFont = UIFont.boldSystemFontOfSize(17.0)
                attributedString = NSMutableAttributedString(string: result.getContext())
                attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, nsContext.length))
                for (var i = 0; i < Int(result.numberOfMatchesInReference()); i++) {
                    var match = result.getMatchWithInt(Int32(i))
                    var textRange = NSRange(location: Int(match.getStartIndex()), length: Int(match.getEndIndex() - match.getStartIndex()))
                    attributedString.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.StyleSingle.rawValue, range: textRange)
                    attributedString.addAttribute(NSFontAttributeName, value: boldFont, range: textRange)
                }
                let fgColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_INFO_PANEL_, withNSString: ALCPropertyName_COLOR_))
                attributedString.addAttribute(NSForegroundColorAttributeName, value: fgColor, range: NSMakeRange(0, nsContext.length))
                mStrings.updateValue(attributedString, forKey: indexPath)
            }
            return attributedString
        }
    }
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let svc = segue.destinationViewController.contentViewController as? ScriptureViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case Constants.SearchGoToVerseSeque :
                    if let nc = segue.destinationViewController as? UINavigationController {
                        nc.setToolbarHidden(false, animated: false)
                        nc.setNavigationBarHidden(true, animated: false)
                    }
                    var selectedResult = mSearchResults[mSelectedIndex!.row]
                    svc.scripture = mScripture
                    svc.mVerseNumber = String(selectedResult.getReference().getFromVerse())
                    svc.bookNumber = mScripture!.findBookFromResult(selectedResult)!.mIndex!
                    svc.chapterNumber = Int(selectedResult.getReference().getChapterNumber())
                    
                default: break
                }
            }
        }
    }
    */
    // MARK: - Search
    func search() {
        AISSearchHandler_initWithALSAppLibrary_withALSDisplayWriter_withAISScriptureFactoryIOS_(searchHandler, mScripture.getLibrary(), mScripture.getDisplayWriter(), mScripture.getFactory())
        self.searchHandler.initSearchWithNSString(mSearchString, withBoolean: mMatchWholeWord!, withBoolean: mMatchAccents!)
        var books = self.mScripture.getLibrary().getMainBookCollection().getBooks()
        var resultCount = 0
        var indexPathArray = [[NSIndexPath]]()
        for (var i = 0; i < Int(books.size()) && !mStopSearch; i++) {
            var indexPaths = [NSIndexPath]()
            autoreleasepool {
                var bookResults = [AISSearchResultIOS]()
                var object: AnyObject! = books.getWithInt(CInt(i))
                self.mBook = object as? ALSBook
                var group = self.mBook?.getGroup()
                if (self.mScripture.searchGroup.isEmpty || (group == self.mScripture.searchGroup)) {
                    let bookId = self.mBook!.getBookId();
                    if (bookId == "COL") {
                        var a = 3
                    }
                    self.searchHandler.loadBookForSearchWithALSBook(mBook)
                    for (var c = 0; c < Int(self.mBook!.getChapters().size()) && !self.mStopSearch; c++) {
                        var chapter = self.searchHandler.initChapterWithALSBook(mBook, withInt: CInt(c))
                        var elements = chapter.getElements()
                        for (var e = 0; e < Int(elements.size()) && !self.mStopSearch; e++) {
                            var element = elements.getWithInt(CInt(e)) as! ALSElement
                            var searchResult = self.searchHandler.searchOneElementWithNSString(bookId, withALSChapter: chapter, withALSElement: element)
                            if (searchResult != nil) {
                                searchResult.setBookNameWithNSString(self.mBook!.getName())
                                resultCount++
                                if (resultCount > Constants.MaxResults) {
                                    self.mStopSearch = true
                                }
                                var indexPath = NSIndexPath(forRow: bookResults.count, inSection: self.mSearchResults.count)
                                indexPaths.append(indexPath)
                                bookResults.append(searchResult)
                            }
                        }
                    }
                }
                self.mTitles.append(mBook!.getAbbrevName())
                self.searchHandler.unloadBookWithALSBook(mBook)
                self.mSearchResults.append(bookResults)
                indexPathArray.append(indexPaths)
            }
            addRowToView(indexPathArray[i])
        }
        if (resultCount == 0) {
            var searchResult = AISSearchResultIOS()
            self.mSearchResults.append([searchResult])
            var indexPath = NSIndexPath(forRow: 0, inSection: 0)
            addRowToView([indexPath])
        }
        self.mStopSearch = false
    }
    func addRowToView(indexPaths: [NSIndexPath]) {
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            if (!self.mClosing) {
                if (indexPaths.count > 0) {
                    self.searchTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
                }
                self.mBooksAdded++
            }
        }
    }
}
