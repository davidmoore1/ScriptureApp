//
//  SearchTableViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit
import WebKit

class SearchTableViewController: UITableViewController {
    var searchHandler = AISSearchHandler()
    var mSearchString : String?
    var mMatchWholeWord : Bool?
    var mMatchAccents : Bool?
    var mScripture: Scripture?
    var mSearchResults = [[AISSearchResultIOS]]()
    var mStopSearch = false
    var mClosing = false
    var mBook: ALSBook?
    var mRowsAdded: Int = 0
    var mScriptureController: ScriptureViewController?
    var mNumberOfBooks = 0
    private var mSelectedIndex: NSIndexPath?
    
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mCloseButton: UIBarButtonItem!
    @IBAction func closeClicked(sender: AnyObject) {
        mStopSearch = true
        mClosing = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.rowHeight = UITableViewAutomaticDimension
        searchTableView.estimatedRowHeight = 135
        
        mNumberOfBooks = Int(mScripture!.getLibrary().getMainBookCollection().getBooks().size())
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navBar.title = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            [unowned self] in
            self.search()
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] in
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return mNumberOfBooks
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if (section > mSearchResults.count - 1) {
            return 0
        }
        return mSearchResults[section].count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerString = ""
        if section <= mSearchResults.count - 1 {
            if mSearchResults[section].count > 0 {
                headerString = mSearchResults[section][0].getBookName()
            }
        }
        return headerString
    }
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColorFromRGB(mScripture!.getConfig().getStylePropertyColorValueWithNSString(ALSStyleName_UI_CHAPTER_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SearchCellReuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell

        // Configure the cell...
        var result = mSearchResults[indexPath.section][indexPath.row]
        if ((indexPath.section == 0) && (indexPath.row == 0) && (result.numberOfMatchesInReference() == 0)) {
            var emptyString = NSMutableAttributedString(string: "")
            cell.reference = mScripture!.getString(ALSScriptureStringId_SEARCH_NO_MATCHES_FOUND_)
            cell.html = emptyString
            return cell
        }
        cell.reference = searchHandler.getReferenceTitleWithALSReference(result.getReference())
        var context = result.getContext()
        var nsContext = context as NSString
        let font = UIFont.systemFontOfSize(17.0)
        let boldFont = UIFont.boldSystemFontOfSize(17.0)
        var attributedString = NSMutableAttributedString(string: result.getContext())
        attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, nsContext.length))
        for (var i = 0; i < Int(result.numberOfMatchesInReference()); i++) {
            var match = result.getMatchWithInt(Int32(i))
            var textRange = NSRange(location: Int(match.getStartIndex()), length: Int(match.getEndIndex() - match.getStartIndex()))
            attributedString.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.StyleSingle.rawValue, range: textRange)
            attributedString.addAttribute(NSFontAttributeName, value: boldFont, range: textRange)
        }
        cell.html = attributedString
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mStopSearch = true
        mSelectedIndex = indexPath
        var selectedResult = mSearchResults[indexPath.section][indexPath.row]
        if ((indexPath.section == 0) && (indexPath.row == 0) && ( selectedResult.numberOfMatchesInReference() == 0 )) {
            // User selected "No results found
            return
        }
        mScriptureController!.mVerseNumber = String(selectedResult.getReference().getFromVerse())
        mScriptureController!.bookNumber = mScripture!.findBookFromResult(selectedResult)!.mIndex!
        mScriptureController!.chapterNumber = Int(selectedResult.getReference().getChapterNumber())
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC) / 4))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
        view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
//        self.performSegueWithIdentifier(Constants.SearchGoToVerseSeque, sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
    func search() {
        AISSearchHandler_initWithALSAppLibrary_withALSDisplayWriter_withAISScriptureFactoryIOS_(searchHandler, mScripture!.getLibrary(), mScripture!.getDisplayWriter(), mScripture!.getFactory())
        self.searchHandler.initSearchWithNSString(mSearchString, withBoolean: mMatchWholeWord!, withBoolean: mMatchAccents!)
        var books = self.mScripture!.getLibrary().getMainBookCollection().getBooks()
        var resultCount = 0
        for (var i = 0; i < Int(books.size()) && !mStopSearch; i++) {
            autoreleasepool {
                var bookResults = [AISSearchResultIOS]()
                var indexPaths = [NSIndexPath]()
                var object: AnyObject! = books.getWithInt(CInt(i))
                self.mBook = object as? ALSBook
                var group = self.mBook?.getGroup()
                if (self.mScripture!.searchGroup.isEmpty || (group == self.mScripture!.searchGroup)) {
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
                self.searchHandler.unloadBookWithALSBook(mBook)
                self.mSearchResults.append(bookResults)
                addRowToView(indexPaths)
            }
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
                    self.tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
                }
            }
        }
    }
}
