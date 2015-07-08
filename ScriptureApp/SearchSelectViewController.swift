//
//  SearchSelectViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/30/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchSelectViewController: UIViewController {

    var mScripture: Scripture?
    var searchHandler = AISSearchHandler()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AISSearchHandler_initWithALSAppLibrary_withALSDisplayWriter_withAISScriptureFactoryIOS_(searchHandler, mScripture!.getLibrary(), mScripture!.getDisplayWriter(), mScripture!.getFactory())
        var btnCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        var matchCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_MATCH_WHOLE_WORDS_)
        var searchHint = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_TEXT_HINT_)
        matchLabel.text = matchCaption
        navBar.title = btnCaption
        searchBar.placeholder = searchHint
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchClicked(sender: UIButton) {
         if searchBar!.text.isEmpty {
            let alert:UIAlertController = UIAlertController(title: "Error", message: "Please enter a serch string!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
        var results = searchHandler.searchForStringWithNSString(searchBar!.text, withBoolean: false , withBoolean: false)
/*        for result in results {
            
        }*/
        }
        
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var matchSwitch: UISwitch!
    @IBOutlet weak var navBar: UINavigationItem!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
