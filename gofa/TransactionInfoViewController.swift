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
    var status: String! // status of request (pending/deferred, accepted, completed, paid)
    
    let urlkind = "gofa-app.com"
    var urlsavebag: String!
    var urlgetbag: String!
    var urlcancelrequest: String!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var openingLineLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var bagLabel: UILabel!
    @IBOutlet weak var bagContents: UILabel!
    @IBOutlet weak var editBagButton: UIButton!
    @IBOutlet weak var saveBagButton: UIButton!
    @IBOutlet weak var bagContentsTextView: UITextView!
    @IBOutlet weak var pendingExtraInfo: UILabel!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var actionType: UILabel!
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        bagContentsTextView.endEditing(true)
    }
    
    @IBAction func editBag(sender: UIButton) {
        sender.hidden = true
        saveBagButton.hidden = false
        bagContentsTextView.editable = true
        bagContentsTextView.becomeFirstResponder()
    }
    
    @IBAction func cancelTransaction(sender: OBShapedButton) {
        var transaction = self.transactionInfo
        var requestInfo:NSDictionary = ["transactionid": transaction["id"] as String!, "userid": self.curUser as String!, "tripOwnerName": transaction["tripOwnerName"] as String!, "locName": transaction["locName"] as String!]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlcancelrequest)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var status = feedback["status"] as String!
                if (status == "success") {
                    println("successfully cancelled request")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.backToTransactions()
                    })
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    @IBAction func back(sender: UIButton) {
        backToTransactions()
    }
    
    func backToTransactions() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let transVC:TransactionViewController = storyboard.instantiateViewControllerWithIdentifier("transactions") as TransactionViewController
        transVC.curUser = self.curUser
        self.presentViewController(transVC, animated: false, completion: nil)
    }
 
    
    @IBAction func saveBag(sender: UIButton) {
        sender.hidden = true
        editBagButton.hidden = false
        bagContentsTextView.endEditing(true)
        bagContentsTextView.editable = false
        var bagContents = bagContentsTextView.text;
        var bagInfo = ["contents": bagContents, "userid": self.curUser, "locationid": self.transactionInfo["location"] as String]
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
        self.urlsavebag = "http://" + urlkind + "/savebag"
        self.urlgetbag = "http://" + urlkind + "/getbag"
        self.urlcancelrequest = "http://" + urlkind + "/cancelRequest"
        println(transactionInfo)
        displayReqTransactionInfo()
    }
    
    func displayReqTransactionInfo() {
        self.userNameLabel.text = self.transactionInfo["tripOwnerName"] as String!
        var toa = self.transactionInfo["toa"] as Int
        let date = NSDate()
        let timestamp = date.timeIntervalSince1970
        toa = (toa - Int(ceil(timestamp)))
        // display in minutes and round down
        toa = Int(floor(Double(toa) / 60.0))
        self.arrivalTimeLabel.text = "\(toa)"
        if self.status == "pending" || self.status == "deferred" {
            displayPendingReqTransaction()
            displayTabHeader(self.status)
        } else if self.status == "accepted" {
            displayAcceptedReqTransaction()
            displayTabHeader(self.status)
        } else if self.status == "delivered" {
            displayCompletedReqTransaction()
        }
    }
    
    func displayPendingReqTransaction() {
        getBag()
        
    }
    
    func displayAcceptedReqTransaction() {
        getBag()
        self.pendingExtraInfo.hidden = true
        self.acceptedLabel.hidden = false
        self.actionType.text = "Message"
        self.actionType.sizeToFit()
        self.actionType.textColor = UIColor.whiteColor()
        self.saveBagButton.hidden = true
        self.saveBagButton.enabled = false
        self.editBagButton.hidden = true
        self.editBagButton.enabled = false
        self.openingLineLabel.text = "Order accepted by"
    }
    
    func displayCompletedReqTransaction() {
    
    }

    
    // displays the transaction tab at the top of the view with the appropriate status details
    func displayTabHeader(status: String!) {
        var transactionTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab.frame = CGRectMake(10, 30, 278, 45)
        transactionTab.center.x = self.view.center.x
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
        locLabel.center = CGPoint(x: tabSize.width/2 - tabSize.width*(3/10), y: tabSize.height/2)
        locLabel.textAlignment = NSTextAlignment.Left
        var nameLabel = UILabel()
        transactionTab.addSubview(nameLabel)
        nameLabel.text = transactionInfo["tripOwnerName"] as String!
        nameLabel.font = UIFont(name: "Futura", size: 11)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: tabSize.width/2, y: tabSize.height/2)
        var statusLabel = UILabel()
        transactionTab.addSubview(statusLabel)
        var transTab: UIImage!
        if status == "pending" || status == "deferred" {
            transTab = UIImage(named: "tab")!
            statusLabel.text = "P"
            statusLabel.textColor = UIColor.whiteColor()
        } else if (status == "accepted") {
            transTab = UIImage(named: "tabgreen")!
            statusLabel.text = "Accepted!"
            statusLabel.textColor = UIColor.greenColor()
        }
        transactionTab.setImage(transTab, forState: UIControlState.Normal)
        statusLabel.font = UIFont(name: "Futura", size: 11)
        statusLabel.sizeToFit()
        statusLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
    }
    
    func getBag() {
        var bagInfo = ["userid": self.curUser, "locationid": transactionInfo["location"] as String]
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
    
}