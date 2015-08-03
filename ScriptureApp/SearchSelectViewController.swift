//
//  SearchSelectViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/30/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchSelectViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate
{

    var mScripture: Scripture?
    let config = Scripture.sharedInstance.getConfig()
    var mScriptureController: ScriptureViewController?
    var specialCharacters: [[String]]!
    var searchTextField: UITextField!
    @IBOutlet weak var specialCharactersCollectionView: UICollectionView!
    @IBOutlet weak var specialCharactersCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var hideKeyboardButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIButton!
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
        matchAccentsSwitch.on = mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_DEFAULT_)
        matchSwitch.on = mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_DEFAULT_)
        matchAccentsSwitch.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_SHOW_)
        matchAccentsLabel.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_ACCENTS_SHOW_)
        matchSwitch.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_SHOW_)
        matchLabel.hidden = !mScripture!.configGetBoolFeature(ALCCommonFeatureName_SEARCH_WHOLE_WORDS_SHOW_)
        searchBar.placeholder = searchHint
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        navigationItem.title = btnCaption
        navigationItem.backBarButtonItem = mScriptureController?.closeButton
        specialCharactersCollectionView.dataSource = self
        specialCharacters = mScripture!.getSpecialCharacters()
        specialCharactersCollectionHeight.constant *= CGFloat(specialCharacters.count)
        searchButton.setTitle(btnCaption, forState: .Normal)
//        searchButton.layer.borderColor = UIColor.grayColor().CGColor
//        searchButton.layer.borderWidth = 1
//        searchRangeLabel.text = mScripture!.getString(ALSScriptureStringId_SEARCH_RANGE_)
//        if mScripture!.searchRange != nil {
//            mRangeButtonText = mScripture!.searchRange!
//        }

        // color theme
        view.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        let checkboxLabelColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_CHECKBOX_, withNSString: ALCPropertyName_COLOR_))
        matchLabel.textColor = checkboxLabelColor
        matchAccentsLabel.textColor = checkboxLabelColor
        searchRangeLabel.textColor = checkboxLabelColor
        specialCharactersCollectionView.backgroundColor = view.backgroundColor
        searchTextField = searchBar.valueForKey("searchField") as? UITextField
        searchTextField.textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_ENTRY_TEXT_, withNSString: ALCPropertyName_COLOR_))
        searchBar.tintColor = searchTextField.textColor
//        searchButton.tintColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_COLOR_))
//        searchButton.backgroundColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        searchRangeButton.tintColor = searchButton.tintColor
        searchRangeButton.backgroundColor = searchButton.backgroundColor
        searchRangeButton.layer.borderWidth = 1
        searchRangeButton.layer.borderColor = UIColor.grayColor().CGColor

        hideKeyboardButton.tintColor = UIColor.clearColor()
        searchTextField.addTarget(self, action: "textChanged:", forControlEvents: .EditingChanged)
    }

    func textChanged(textField: UITextField) {
        searchButton.enabled = !textField.text.isEmpty
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @IBAction func searchButtonPress(sender: UIButton) {
        searchBarSearchButtonClicked(searchBar)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return specialCharacters.count
    }

    @IBAction func hideKeyboard(sender: UIBarButtonItem) {
        searchTextField.resignFirstResponder()
    }

    func keyboardWillShow() {
        // navigationItem.setRightBarButtonItems([hideKeyboardButton], animated: true)
        // navigationItem.rightBarButtonItem = hideKeyboardButton
        hideKeyboardButton.tintColor = UIColor.whiteColor()
        hideKeyboardButton.enabled = true
    }

    func keyboardWillHide() {
        // navigationItem.setRightBarButtonItems(nil, animated: true)
        // navigationItem.rightBarButtonItem = nil
        hideKeyboardButton.tintColor = UIColor.clearColor()
        hideKeyboardButton.enabled = false
        searchTextField.resignFirstResponder()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialCharacters[section].count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.SpecialCharacterCell, forIndexPath: indexPath) as! SpecialCharacterCell
        let title = specialCharacters[indexPath.section][indexPath.item]
        let bgColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        let fgColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_COLOR_))

        cell.button.setTitle(title, forState: .Normal)
        cell.button.backgroundColor = bgColor
        cell.button.setTitleColor(fgColor, forState: .Normal)

        cell.button.layer.borderColor = UIColor.grayColor().CGColor
        cell.button.layer.borderWidth = 1

        cell.textField = searchTextField

        return cell
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
                if let tvc = segue.destinationViewController.contentViewController as? SearchResultsViewController {
                    searchBar.resignFirstResponder()
                    tvc.mSearchString = searchBar!.text
                    tvc.mMatchWholeWord = matchSwitch!.on
                    tvc.mMatchAccents = matchAccentsSwitch!.on
                    tvc.mScriptureController = mScriptureController
                }
            case Constants.SearchRangeSeque:
                if let tvc = segue.destinationViewController.contentViewController as? SearchRangeViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                        tvc.modalPresentationStyle = UIModalPresentationStyle.Popover
                        tvc.searchSelectController = self
                    }
                }

            default: break
            }
        }
    }

}

class SpecialCharacterCell: UICollectionViewCell {
    var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBAction func selectCharacter(sender: UIButton) {
        textField.text = textField.text + sender.currentTitle!
        textField.sendActionsForControlEvents(.EditingChanged)
    }
}

