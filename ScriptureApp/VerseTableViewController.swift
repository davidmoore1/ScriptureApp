//
//  VerseTableViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/24/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem()
        UIApplication.sharedApplication().sendAction(barButtonItem.action, to: barButtonItem.target, from: nil, forEvent: nil)
    }
}

class VerseTableViewController: UITableViewController {
    var mSelectedIndex: NSIndexPath?
    var mSelectedBook: ALSBook?
    var mScripture: Scripture?
    var mSelectedBookIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mSelectedBook = mScripture!.getBook(mSelectedBookIndex!)
        var success = false
        (success, mSelectedBook) = mScripture!.loadBook(mSelectedBook)
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var retVal = 1;
        let numberOfChapters = mScripture?.numberOfChaptersInBook(mSelectedBook)
        if (numberOfChapters > 0) {
            retVal = numberOfChapters!
        }
        return retVal
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "Verse"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        var chapterNumber = indexPath.row + 1
        cell.textLabel?.text =  String(chapterNumber)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        mSelectedIndex = indexPath
        self.splitViewController?.toggleMasterView()
        self.performSegueWithIdentifier("DisplayChapter", sender: self)
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let ivc = segue.destinationViewController.contentViewController as? DetailViewController {
            if let identifier = segue.identifier {
                var chapterHTML: String? = nil
                var success: Bool = false
                switch identifier {
                case "DisplayChapter" :
                    ivc.mScripture = mScripture
                    var chapterNumber = mSelectedIndex!.row + 1
                    (success, chapterHTML) = mScripture!.getChapter(chapterNumber)
                    ivc.navigationItem.title = mScripture!.getFormattedBookChapter()
                    if (success) {
                        ivc.html = chapterHTML!
                    }
                    
                default: break
                }
            }
        }
    }


}
