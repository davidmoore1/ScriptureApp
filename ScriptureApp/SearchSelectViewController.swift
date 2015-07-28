//
//  SearchSelectViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/30/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchSelectViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource {

    var mScripture: Scripture?
    let config = Scripture.sharedInstance.getConfig()
    var mScriptureController: ScriptureViewController?
    var specialCharacters: [[String]]!
    var searchTextField: UITextField!
    @IBOutlet weak var specialCharactersCollectionView: UICollectionView!
    @IBOutlet weak var specialCharactersCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var hideKeyboardButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var btnCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        var matchCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_MATCH_WHOLE_WORDS_)
        var searchHint = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_TEXT_HINT_)
        matchLabel.text = matchCaption
        searchBar.placeholder = searchHint
        searchBar.delegate = self
        navigationItem.title = btnCaption
        navigationItem.backBarButtonItem = mScriptureController?.closeButton
        specialCharactersCollectionView.dataSource = self
        specialCharacters = mScripture!.getSpecialCharacters()
        specialCharactersCollectionHeight.constant *= CGFloat(specialCharacters.count)
        searchButton.setTitle(btnCaption, forState: .Normal)
        searchButton.layer.borderColor = UIColor.grayColor().CGColor
        searchButton.layer.borderWidth = 1
        
        // color theme
        view.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
        matchLabel.textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_CHECKBOX_, withNSString: ALCPropertyName_COLOR_))
        specialCharactersCollectionView.backgroundColor = view.backgroundColor
        searchTextField = searchBar.valueForKey("searchField") as? UITextField
        searchTextField.textColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_ENTRY_TEXT_, withNSString: ALCPropertyName_COLOR_))
        searchBar.tintColor = searchTextField.textColor
        searchButton.tintColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_COLOR_))
        searchButton.backgroundColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_BUTTON_, withNSString: ALCPropertyName_BACKGROUND_COLOR_))
        
        hideKeyboardButton.tintColor = UIColor.clearColor()
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        mScriptureController?.navbar?.updateNavigationBarColors()
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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var matchSwitch: UISwitch!
    
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
                    tvc.mScripture = mScripture
                    tvc.mScriptureController = mScriptureController
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
    }
}

extension Scripture {
    func getSpecialCharacters() -> [[String]] {
        // return [["a", "b", "c"], ["d", "e", "f", "g"], ["hello"], ["world"], ["this", "is", "a", "test"], map("abcdefghijklmnop") { "\($0)" }, ["c"] ] // + map("1234567890") { ["\($0)"] }
        return getConfig().getInputButtonLines().map {
            let row = $0 as! ALCInputButtonRow
            let buttons = (row.getButtons() as! JavaUtilAbstractList).map { $0 as! ALCInputButton }
            let forms = buttons.map { $0.getDisplayForm() }
            let strings = forms.map { ALCStringUtils_convertCharCodesToStringWithNSString_($0)! }
            return strings
        }
    }
}