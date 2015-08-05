//
//  SearchRangeViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 7/24/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchRangeViewController: CommonViewController, UITableViewDataSource, UITableViewDelegate {

    var searchGroups: NSMutableArray! = NSMutableArray()
    var searchSelectController: SearchSelectViewController!
    var tableData: NSMutableArray! = NSMutableArray()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableData.addObject(scripture.getString(ALSScriptureStringId_SEARCH_WHOLE_BIBLE_))
        self.tableData.addObject(scripture.OTName)
        self.tableData.addObject(scripture.NTName)

        searchGroups.addObject("")
        searchGroups.addObject("OT")
        searchGroups.addObject("NT")

        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()

        let bgColor = scripture.getPopupBackgroundColor()
        popoverPresentationController?.backgroundColor = bgColor
        view.backgroundColor = bgColor
    }

    // MARK: - UITableViewDataSource

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(Constants.SearchRangeCellReuseIdentifier) as! UITableViewCell
        cell.textLabel?.text = self.tableData.objectAtIndex(indexPath.row) as? String
        cell.textLabel?.textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_CHECKBOX_, withNSString: ALCPropertyName_COLOR_))
        cell.backgroundColor = scripture.getPopupBackgroundColor()
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchSelectController.mRangeButtonText = self.tableData.objectAtIndex(indexPath.row) as! String
        scripture.searchGroup = searchGroups.objectAtIndex(indexPath.row) as! String
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
