//
//  SearchRangeViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 7/24/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchRangeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let scripture = Scripture.sharedInstance
    let config = Scripture.sharedInstance.getConfig()
    var searchGroups: NSMutableArray! = NSMutableArray()
    var searchSelectController: SearchSelectViewController!
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableView
    var tableData: NSMutableArray! = NSMutableArray()
    @IBOutlet weak var tableView: UITableView!

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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchSelectController.mRangeButtonText = self.tableData.objectAtIndex(indexPath.row) as! String
        scripture.searchGroup = searchGroups.objectAtIndex(indexPath.row) as! String
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
