//
//  BookTableViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/23/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class BookTableViewController: UITableViewController, UITableViewDelegate {
    private var mScripture: Scripture = Scripture()
    private var mSelectedIndex: NSIndexPath?
    private var books = [[Book]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        mScripture.loadLibrary()
        var groupIndex = 0
        var currentGroupString = ""
        var groupNumber = 0
        books.removeAll()
        var bookArray = [Book]()
        for (var i=0; i<mScripture.numberOfBooks; i++) {
            let book = mScripture.getBook(i)
            let bookGroupString = mScripture.getBookGroupString(book!, firstBook: (i == 0))
            if bookGroupString.newGroup {
                if bookArray.count > 0 {
                    books.append(bookArray)
                    groupNumber++
                    groupIndex = 0
                    bookArray.removeAll()
                }
                currentGroupString = bookGroupString.bookGroupString
            }
            let bookForArray = Book(book: book, index: i, group: groupNumber, groupIndex: groupIndex, groupString: currentGroupString)
            groupIndex++
            bookArray.append(bookForArray)
        }
        if (bookArray.count > 0) {
            books.append(bookArray)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return books.count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "Book"
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return books[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! BookTableViewCell

        // Configure the cell...
        cell.book = books[indexPath.section][indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        mSelectedIndex = indexPath
        self.performSegueWithIdentifier("ShowChapters", sender: self)
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
        var book: ALSBook? = nil;
        if let verseTVC = segue.destinationViewController.contentViewController as? VerseTableViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "ShowChapters" :
                    verseTVC.mScripture = mScripture
                    verseTVC.mSelectedBookIndex = mSelectedIndex!.section
                default: break
                }
            }
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        }
        return self
    }
}
