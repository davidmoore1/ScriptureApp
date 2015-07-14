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
    var mSelectedBook: Book?
    var mScripture: Scripture?
    var mSelectedBookIndex: NSIndexPath?
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let numberOfChapters = mSelectedBook!.numberOfChapters()
        if (numberOfChapters > 0) {
            retVal = numberOfChapters
        }
        if (mSelectedBook!.hasIntroduction()) {
            retVal++
        }
        return retVal
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.VerseCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        if (indexPath.row == 0) {
            cell.textLabel?.text = mSelectedBook!.hasIntroduction() ? mScripture!.getString(ALSScriptureStringId_CHAPTER_INTRODUCTION_TITLE_) : "1"
        } else {
            var chapterNumber = mSelectedBook!.hasIntroduction() ? indexPath.row : indexPath.row + 1
            cell.textLabel?.text =  String(chapterNumber)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        mSelectedIndex = indexPath
        self.performSegueWithIdentifier(Constants.DisplayChapterSeque, sender: self)
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
                switch identifier {
                case Constants.DisplayChapterSeque :
                    ivc.mScripture = mScripture
                    ivc.mSelectedBook = mSelectedBook
                    ivc.mSelectedVerse = ""
                    ivc.mSelectedChapter = mSelectedBook!.hasIntroduction() ? mSelectedIndex!.row : mSelectedIndex!.row + 1
                    
                default: break
                }
            }
        }
    }


}
