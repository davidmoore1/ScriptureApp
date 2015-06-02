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
    var mLibrary: ALSAppLibrary = ALSAppLibrary()
    
    @IBOutlet weak var MyTextView: UITextView!
    @IBOutlet weak var answerLabel2: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickedPushMe(sender: UIButton) {
        let appConfig = ALCAppConfig();
        appConfig.initConfig()

        var myString = "list"
        
        var result = ALCStringUtils_isBlankWithNSString_(myString)
        if (result) {
            answerLabel.text = "blank"
        }
        else {
            answerLabel.text = "not blank"
        }
        
        let encryptor = Encryption()
        var encryptedValue = encryptor.encryptWithNSString("TestPassword")
        answerLabel.text = encryptedValue
        var decryptedValue = encryptor.decryptWithNSString(answerLabel.text)
        answerLabel2.text = decryptedValue
        loadConfig()
        testObfucate()
    }
    
    func loadConfig() {
        var bundle = NSBundle.mainBundle()
        
        // using paths...
        if let bundlePath = bundle.resourcePath
        {
            var assetsPath = bundlePath + "/assets"
            let (contents, errOpts) = contentsOfDirectoryAtPath(assetsPath)
            let configFile = AASCommonFactory_getConfigFilenameWithJavaUtilList_(stringToUtilList(contents!))
            var isEncrypted = AASCommonFactory_isEncryptedFileWithNSString_(configFile)
            let factory = IOSFactory()
            var fullFilePath = assetsPath + "/" + configFile
            var sb = factory.loadExternalFileToStringBuilderWithNSString(fullFilePath, withBoolean: isEncrypted)
            var string = sb.substringWithInt(0)
            MyTextView.text = string
            var xmlString = sb.description()
            var ioStream = xmlString.getBytesWithCharsetName("UTF-8")
            var sbInputStream = new_JavaIoByteArrayInputStream_initWithByteArray_(ioStream)
            let parser = ALSConfigParser()
            parser.setLibraryWithALSAppLibrary(mLibrary)
            parser.setInputStreamWithJavaIoInputStream(sbInputStream)
 //           parser.parse()
            
        }
    }
    
    func testObfucate() {
        var obfuscatedString = ALCc.obfuscateWithNSString("This is a test")
        var deobfuscatedString = ALCc.deobfuscateWithNSString(obfuscatedString)
        answerLabel2.text = deobfuscatedString
        
    }
    func loadBook() {
        var bundle = NSBundle.mainBundle()
        
        // using paths...
        if let bundlePath = bundle.resourcePath
        {
            var assetsPath = bundlePath + "/assets"
            let bookFile = "i2vQpoMmm92qkjx8K4jk"
            var fullFilePath = assetsPath + "/" + bookFile
        }
    
    }
    // Get contents of directory at specified path, returning (filenames, nil) or (nil, error)
    func contentsOfDirectoryAtPath(path: String) -> (filenames: [String]?, error: NSError?) {
        var error: NSError? = nil
        let fileManager = NSFileManager.defaultManager()
        let contents = fileManager.contentsOfDirectoryAtPath(path, error: &error)
        if contents == nil {
            return (nil, error)
        }
        else {
            let filenames = contents as! [String]
            return (filenames, nil)
        }
    }
    
    func stringToUtilList(strings: [String]) -> (JavaUtilList) {
        let utilList = new_JavaUtilArrayList_init()
        for entry in strings {
            utilList.addWithId(entry)
        }
        return utilList
    }
    
    func utilListToStringArray(javaArray: JavaUtilList) -> [String] {
        var stringArray = [String]()
        var iterator = javaArray.iterator()
        while (iterator.hasNext()) {
            var object = iterator.next()
            stringArray.append(object as! String)
        }
        return stringArray
    }
    
}

