//
//  TransactionInfoController.swift
//  gofa
//
//  Created by Andrew Grant on 3/31/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class TransactionInfoViewController: UIViewController
{
    var curUser: String!
    var transactionInfo = [String: AnyObject]()
    var tripInfo = [String: AnyObject]()
    
    
    let urlsavebag = "http://localhost:3000/savebag"
    let urlgetbag = "http://localhost:3000/getbag"
    
    @IBOutlet weak var pendingLine: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var bagLabel: UILabel!
    @IBOutlet weak var bagContents: UILabel!
    @IBOutlet weak var editBagButton: UIButton!
    @IBOutlet weak var saveBagButton: UIButton!
    @IBOutlet weak var bagContentsTextView: UITextView!
   
    
    @IBAction func editBag(sender: UIButton) {
        sender.hidden = true
        saveBagButton.hidden = false
        bagContentsTextView.becomeFirstResponder()
    }
    
    @IBAction func cancelTransaction(sender: OBShapedButton) {
        
    }
    
    @IBAction func saveBag(sender: UIButton) {
        sender.hidden = true
        editBagButton.hidden = true
        bagContentsTextView.endEditing(true)
        var bagContents = bagContentsTextView.text;
        var bagInfo = ["contents": bagContents, "userid": self.curUser, "locationid": self.tripInfo["location"] as String]
        var bagData = NSJSONSerialization.dataWithJSONObject(bagInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlsavebag)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = bagData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("the data..")
                println(data)
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var status = feedback["status"] as String!
                if (status == "success") {
                    println("successfully saved bag")
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(transactionInfo)
        self.tripInfo = self.transactionInfo["tripInfo"] as [String: AnyObject] //keys: locid, toa, typeoftrip, userid(trip owner)
        if transactionInfo["request"] as Bool {
            displayReqTransactionInfo()
        } else {
            displayResponseTransactionInfo()
        }
    }
    
    
    func getBag() {
        var bagInfo = ["userid": self.curUser, "locationid": tripInfo["location"] as String]
        var bagData = NSJSONSerialization.dataWithJSONObject(bagInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgetbag)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = bagData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("the data..")
                println(data)
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                println("successfully got bag contents")
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.bagContentsTextView.text = feedback["contents"] as? String
                })
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    func displayReqTransactionInfo() {
        var transactionTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab.frame = CGRectMake(10, 30, 278, 45)
        transactionTab.center.x = self.view.center.x
        var status = transactionInfo["transStatus"] as String
        if status == "pending" {
            displayPendingReqTransaction(transactionTab)
        } else if status == "accepted" {
            displayAcceptedReqTransaction()
        } else if status == "completed" {
            displayCompletedReqTransaction()
        }
    }
    
    func displayPendingReqTransaction(transactionTab: OBShapedButton) {
        getBag()
        println("should be showing")
        var transTab = UIImage(named: "tab")
        println(transTab)
        transactionTab.setImage(transTab, forState: UIControlState.Normal)
        transactionTab.alpha = 0.8
        self.view.addSubview(transactionTab)
        var locLabel = UILabel()
        transactionTab.addSubview(locLabel)
        var locName = transactionInfo["locName"] as String!
        locName.replaceRange(locName.startIndex...locName.startIndex, with: String(locName[locName.startIndex]).capitalizedString)
        locLabel.text = locName
        locLabel.font = UIFont(name: "Futura", size: 11)
        locLabel.textColor = UIColor.whiteColor()
        locLabel.sizeToFit()
        var tabSize = transactionTab.frame.size
        locLabel.center = CGPoint(x: tabSize.width/2 - tabSize.width*(3/8), y: tabSize.height/2)
        var nameLabel = UILabel()
        transactionTab.addSubview(nameLabel)
        nameLabel.text = transactionInfo["custName"] as String!
        nameLabel.font = UIFont(name: "Futura", size: 11)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: tabSize.width/2, y: tabSize.height/2)
        var statusLabel = UILabel()
        transactionTab.addSubview(statusLabel)
        statusLabel.text = "P"
        statusLabel.font = UIFont(name: "Futura", size: 11)
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.sizeToFit()
        statusLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        println(transactionTab)
    }
    
    func displayAcceptedReqTransaction() {
        
    }
    
    func displayCompletedReqTransaction() {
    
    }

    func displayResponseTransactionInfo() {
    
    }
    
}