//
//  ViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 5/14/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var answerLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickedPushMe(sender: UIButton) {
        let appConfig = ALCAppConfig();
        appConfig.initConfig()

        var myString = "list"
        
        var result = ALCUStringUtils_isBlankWithNSString_(myString)
        if (result) {
            answerLabel.text = "blank"
        }
        else {
            answerLabel.text = "not blank"
        }

    }

}

