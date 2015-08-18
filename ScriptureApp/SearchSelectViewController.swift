//
//  SearchSelectViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/30/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchSelectViewController: CommonViewController, UISearchBarDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate {

    // MARK: - Properties

    var mScriptureController: ScriptureViewController?
    var specialCharacters: [[String]]!
    var searchTextField: UITextField!
    let searchInfo = SearchInfo.sharedInstance

    var mRangeButtonText: String = "" {
        didSet{
            if searchRangeButton != nil {
                searchRangeButton!.setTitle(mRangeButtonText, forState: UIControlState.Normal)
            }
            scripture.searchRange = mRangeButtonText
        }
    }

    
    // MARK: - IB Outlets

    @IBOutlet weak var specialCharactersCollectionView: UICollectionView!
    @IBOutlet weak var specialCharactersCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var hideKeyboardButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchRangeLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var matchAccentsLabel: UILabel!
    @IBOutlet weak var matchSwitch: UISwitch!
    @IBOutlet weak var matchAccentsSwitch: UISwitch!
    @IBOutlet weak var searchRangeButton: UIButton!

    // MARK: - Actions

    @IBAction func searchButtonPress(sender: UIButton) {
        searchBarSearchButtonClicked(searchBar)
    }

    func textChanged(textField: UITextField) {
        searchButton.enabled = !textField.text.isEmpty
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

    @IBAction func hideKeyboard(sender: UIBarButtonItem) {
        searchTextField.resignFirstResponder()
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

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var btnCaption = scripture.getSearchButtonTitle()
        var matchCaption = scripture.getMatchWholeWordsTitle()
        var searchHint = scripture.getSearchHint()
        matchAccentsLabel.text = scripture.getMatchAccentsTitle()
        matchLabel.text = matchCaption
        matchAccentsSwitch.on = scripture.hasMatchAccentsDefault()
        matchSwitch.on = scripture.hasMatchWholeWordsDefault()
        matchAccentsSwitch.hidden = !scripture.hasMatchAccents()
        matchAccentsLabel.hidden = !scripture.hasMatchAccents()
        matchSwitch.hidden = !scripture.hasMatchWholeWords()
        matchLabel.hidden = !scripture.hasMatchWholeWords()
        searchBar.delegate = self
        searchBar.placeholder = searchHint
        searchBar.becomeFirstResponder()
        navigationItem.title = btnCaption
        navigationItem.backBarButtonItem = mScriptureController?.closeButton
        specialCharactersCollectionView.dataSource = self
        specialCharacters = scripture.getSpecialCharacters()
        specialCharactersCollectionHeight.constant *= CGFloat(specialCharacters.count)
        searchButton.setTitle(btnCaption, forState: .Normal)
//        searchButton.layer.borderColor = UIColor.grayColor().CGColor
//        searchButton.layer.borderWidth = 1
//        searchRangeLabel.text = mScripture!.getString(ALSScriptureStringId_SEARCH_RANGE_)
//        if mScripture!.searchRange != nil {
//            mRangeButtonText = mScripture!.searchRange!
//        }

        // color theme
        view.backgroundColor = scripture.getViewerBackgroundColor()
        let checkboxLabelColor = scripture.getSearchCheckboxLabelColor()
        matchLabel.textColor = checkboxLabelColor
        matchAccentsLabel.textColor = checkboxLabelColor
        searchRangeLabel.textColor = checkboxLabelColor
        specialCharactersCollectionView.backgroundColor = view.backgroundColor
        searchTextField = searchBar.valueForKey("searchField") as? UITextField
        searchTextField.textColor = scripture.getSearchEntryTextColor()
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.SearchResultsSeque:
                if let tvc = segue.destinationViewController.contentViewController as? SearchResultsViewController {
                    searchBar.resignFirstResponder()
                    if (searchInfo.booksAdded == 0) {
                        searchInfo.searchString = searchBar!.text
                        searchInfo.matchWholeWords = matchSwitch!.on
                        searchInfo.matchAccents = matchAccentsSwitch!.on
                    }
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

    // MARK: - UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return specialCharacters.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialCharacters[section].count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.SpecialCharacterCell, forIndexPath: indexPath) as! SpecialCharacterCell
        let title = specialCharacters[indexPath.section][indexPath.item]
        let bgColor = scripture.getSearchButtonBackgroundColor()
        let fgColor = scripture.getSearchButtonColor()

        cell.button.setTitle(title, forState: .Normal)
        cell.button.backgroundColor = bgColor
        cell.button.setTitleColor(fgColor, forState: .Normal)

        cell.button.layer.borderColor = UIColor.grayColor().CGColor
        cell.button.layer.borderWidth = 1

        cell.textField = searchTextField

        return cell
    }

    // MARK: - UIPopoverPresentationControllerDelegate

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

}

// MARK: - SpecialCharacterCell
class SpecialCharacterCell: UICollectionViewCell {
    var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBAction func selectCharacter(sender: UIButton) {
        textField.text = textField.text + sender.currentTitle!
        textField.sendActionsForControlEvents(.EditingChanged)
    }
}
