//
//  SearchTableViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    var searchHandler = AISSearchHandler()
    var mSearchString : String?
    var mMatchWholeWord : Bool?
    var mScripture: Scripture?
    var mSearchResults = [ALSSearchResult]()
    var mStopSearch = false
    var mBook: ALSBook?
    var mScriptureController: ScriptureViewController?
    private var mSelectedIndex: NSIndexPath?
    
    /*        var results = searchHandler.searchForStringWithNSString(searchBar!.text, withBoolean: false , withBoolean: false)
    for result in results {
    
    }*/
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mCloseButton: UIBarButtonItem!
    @IBAction func closeClicked(sender: AnyObject) {
        mStopSearch = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        mCloseButton.title = mScripture!.getString(ALCCommonStringId_BUTTON_CLOSE_)
        activityIndicator.startAnimating()
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        mScripture!.clearBookArray()
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return mSearchResults.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SearchCellReuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell

        // Configure the cell...
        var result = mSearchResults[indexPath.row]
        cell.searchResult = result
        cell.reference = searchHandler.getReferenceTitleWithALSReference(result.getReference())
        cell.html = mScripture!.getHtml(result.getContext())
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mStopSearch = true
        mSelectedIndex = indexPath
        var selectedResult = mSearchResults[mSelectedIndex!.row]
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
        searchHandler.initSearchWithNSString(mSearchString, withBoolean: mMatchWholeWord!, withBoolean: false)
        var books = mScripture!.getLibrary().getMainBookCollection().getBooks()
        for (var i = 0; i < Int(books.size()) && !mStopSearch; i++) {
            autoreleasepool {
            var object: AnyObject! = books.getWithInt(CInt(i))
            mBook = object as? ALSBook
            let bookId = mBook!.getBookId();
            searchHandler.loadBookForSearchWithALSBook(mBook)
            for (var c = 0; c < Int(mBook!.getChapters().size()) && !mStopSearch; c++) {
                var chapter = searchHandler.initChapterWithALSBook(mBook, withInt: CInt(c))
                var elements = chapter.getElements()
                for (var e = 0; e < Int(elements.size()) && !mStopSearch; e++) {
                    var element = elements.getWithInt(CInt(e)) as! ALSElement
                    var searchResult = searchHandler.searchOneElementWithNSString(bookId, withALSChapter: chapter, withALSElement: element)
                    if (searchResult != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            var row = self.mSearchResults.count
                            var indexPath = NSIndexPath(forRow:row, inSection:0)
                            self.mSearchResults.append(searchResult)
                            self.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                        }
                    }
                }
            }
            searchHandler.unloadBookWithALSBook(mBook)
            }
        }
        mStopSearch = false
    }

}
