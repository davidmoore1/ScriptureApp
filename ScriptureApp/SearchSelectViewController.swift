//
//  SearchSelectViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/30/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchSelectViewController: UIViewController, UISearchBarDelegate, UIPopoverPresentationControllerDelegate
 {

    var mScripture: Scripture?
    var mScriptureController: ScriptureViewController?
    var mRangeButtonText: String = "" {
        didSet{
            if searchRangeButton != nil {
                searchRangeButton!.setTitle(mRangeButtonText, forState: UIControlState.Normal)
            }
            mScripture!.searchRange = mRangeButtonText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var btnCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        var matchCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_MATCH_WHOLE_WORDS_)
        var searchHint = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_TEXT_HINT_)
        matchAccentsLabel.text = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_MATCH_ACCENTS_)
        matchLabel.text = matchCaption
        navBar.title = btnCaption
        searchBar.placeholder = searchHint
        searchRangeLabel.text = mScripture!.getString(ALSScriptureStringId_SEARCH_RANGE_)
        if mScripture!.searchRange != nil {
            mRangeButtonText = mScripture!.searchRange!
        }
        matchAccentsSwitch.on = mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_DEFAULT_)
        matchSwitch.on = mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_DEFAULT_)
        matchAccentsSwitch.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_SHOW_)
        matchAccentsLabel.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_SHOW_)
        matchSwitch.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_SHOW_)
        matchLabel.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_SHOW_)
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBarSearchButtonClicked(searchBar: UISearchBar) {
         if searchBar.text.isEmpty {
            let alert:UIAlertController = UIAlertController(title: "Error", message: "Please enter a search string!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.performSegueWithIdentifier(Constants.SearchResultsSeque, sender: self)
        }
        
    }
    @IBOutlet weak var searchRangeLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var matchAccentsLabel: UILabel!
    @IBOutlet weak var matchSwitch: UISwitch!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var matchAccentsSwitch: UISwitch!
    @IBOutlet weak var searchRangeButton: UIButton!

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
/*    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        if (annotationWaiting) {
            annotationWaiting = false
            return UIModalPresentationStyle.None
        }
        return UIModalPresentationStyle.CurrentContext
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.SearchResultsSeque:
                if let tvc = segue.destinationViewController.contentViewController as? SearchTableViewController {
                    searchBar.resignFirstResponder()
                    tvc.mSearchString = searchBar!.text
                    tvc.mMatchWholeWord = matchSwitch!.on
                    tvc.mMatchAccents = matchAccentsSwitch!.on
                    tvc.mScripture = mScripture
                    tvc.mScriptureController = mScriptureController
                }
            case Constants.SearchRangeSeque:
                if let tvc = segue.destinationViewController.contentViewController as? SearchRangeViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                        tvc.modalPresentationStyle = UIModalPresentationStyle.Popover
                    }
                }
                
            default: break
            }
        }
    }

}
