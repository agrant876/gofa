//
//  TransactionInfoResponseViewController.swift
//  gofa
//
//  Created by Andrew Grant on 4/5/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class TransactionInfoResponseViewController: UIViewController
{
    var curUser: String!
    var transactionInfo = [String: AnyObject]()
    var tripInfo = [String: AnyObject]()
    var status: String! // status of request (pending/deferred, accepted, completed, paid)
    
    let urlkind = "gofa-app.com"
    var urlgetbag: String!
    var urlpinguseraccept: String!
    var urlpinguserreject: String!
    var urlpinguserdelivered: String!

    @IBOutlet weak var custNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var willPayLabel: UILabel!
    @IBOutlet weak var actionType: UILabel!
    @IBOutlet weak var actionType2: UILabel!
    @IBOutlet weak var bagContentsTextView: UITextView!
    @IBOutlet weak var contextLabel: UILabel!
    @IBOutlet weak var toaContextLabel: UILabel!
    @IBOutlet weak var actionButton: OBShapedButton!
    @IBOutlet weak var actionButton2: OBShapedButton!
    @IBOutlet weak var userLocLabel: UILabel!
    @IBOutlet weak var willPay2Label: UILabel!
    @IBOutlet weak var chargeLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var colonLabel: UILabel!
    @IBOutlet weak var willPayLabel3: UILabel!
    @IBOutlet weak var bagCost: UITextField!
    @IBOutlet weak var costOfItemsLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dollarSignLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.bagCost.endEditing(true)
        var totalCost = (self.bagCost.text! as NSString).floatValue +
            (self.willPayLabel3.text! as NSString).floatValue
        self.totalCostLabel.text = NSString(format: "%.2f", totalCost)
    }
    
    
    @IBAction func selectedAction1(sender: OBShapedButton) {
        if actionType.text == "Accept" {
            acceptRequest()
        } else if actionType.text == "Message" {
        
        }
    }
    
    @IBAction func selectedAction2(sender: OBShapedButton) {
        if actionType2.text == "Can't do it" {
            rejectRequest()
        } else if actionType2.text == "Delivered" {
            delivered()
        }

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlgetbag = "http://" + urlkind + "/getbag"
        self.urlpinguseraccept = "http://" + urlkind + "/pingUserAccept"
        self.urlpinguserreject = "http://" + urlkind + "/pingUserReject"
        self.urlpinguserdelivered = "http://" + urlkind + "/pingUserDelivered"
        //println(transactionInfo)
        /*if let tinfo = self.transactionInfo["tripInfo"] as [String: AnyObject]? {
            self.tripInfo = tinfo //keys: locid, toa, typeoftrip, userid(trip owner)
        }*/
        displayResTransactionInfo()
    }
    
    func displayResTransactionInfo() {
        self.custNameLabel.text = self.transactionInfo["custName"] as String!
        var locName = self.transactionInfo["locName"] as String!
        locName.replaceRange(locName.startIndex...locName.startIndex, with: String(locName[locName.startIndex]).capitalizedString)
        self.locationLabel.text = locName
        println(self.transactionInfo["userLoc"])
        self.userLocLabel.text = self.transactionInfo["userLoc"] as String!
        self.amountLabel.text = "$" + (self.transactionInfo["willPay"] as String!)
        var toa = transactionInfo["toa"] as Int
        let date = NSDate()
        let timestamp = date.timeIntervalSince1970
        toa = (toa - Int(ceil(timestamp)))
        // display in minutes and round down
        toa = Int(floor(Double(toa) / 60.0))
        if (toa >= 0) {
            self.arrivalTimeLabel.text = "\(toa)"
        } else {
            self.arrivalTimeLabel.text = "0"
        }
        if self.status == "pending" || self.status == "deferred" {
            displayPendingResTransaction()
            displayTabHeader(self.status)
        } else if self.status == "accepted" {
            displayAcceptedResTransaction()
            displayTabHeader(self.status)
        } else if self.status == "delivered" {
            displayDeliveredResTransaction()
            displayTabHeader(self.status)
        }
    }
    
    func displayPendingResTransaction() {
        getBag()
        
        
    }
    
    func displayAcceptedResTransaction() {
        getBag()
        self.statusLabel.hidden = true
        self.willPayLabel.hidden = true
        self.chargeLabel.hidden = false
        self.bagCost.hidden = false
        self.plusLabel.hidden = false
        self.colonLabel.hidden = false
        self.costOfItemsLabel.hidden = false
        self.totalCostLabel.hidden = false
        self.willPayLabel3.hidden = false
        self.dollarSignLabel.hidden = false
        self.willPayLabel3.text = transactionInfo["willPay"] as? String
        self.totalCostLabel.text = self.willPayLabel3.text!
        self.willPayLabel.hidden = true
        self.amountLabel.hidden = true
        self.actionType.text = "Message"
        self.actionType.sizeToFit()
        self.actionType.textColor = UIColor.whiteColor()
        self.actionType2.text = "Delivered"
        self.actionType2.textColor = UIColor.whiteColor()
        self.contextLabel.text = "is excited to get his things from"
        self.toaContextLabel.text = "You arrive at store in"
    }
    
    func displayDeliveredResTransaction() {
        getBag()
        self.statusLabel.hidden = true
        self.deliveredLabel.hidden = false
        self.actionType.hidden = true
        self.actionType2.hidden = true
        self.actionButton.hidden = true
        self.actionButton2.hidden = true
        self.bagCost.enabled = false
        self.contextLabel.text = self.custNameLabel.text //hack
        self.custNameLabel.text = "Awaiting payment from"  //hack
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
            statusLabel.text = "Pending"
            statusLabel.textColor = UIColor.whiteColor()
        } else if (status == "accepted") {
            transTab = UIImage(named: "tabgreen")!
            statusLabel.text = "Accepted"
            statusLabel.textColor = UIColor.greenColor()
        } else if (status == "delivered") {
            transTab = UIImage(named: "tabgreen")!
            statusLabel.text = "Delivered"
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
    
    func acceptRequest() {
        var transaction = self.transactionInfo
        var requestInfo:NSDictionary = ["transactionid": transaction["id"] as String!, "userid": self.curUser as String!]
        var acceptData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlpinguseraccept)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = acceptData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var status = feedback["status"] as String!
                if (status == "success") {
                    println("successfully sent acceptance of request to" + (requestInfo["userid"] as String!))
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayAcceptedResTransaction()
                        self.statusLabel.text = "Accepted"
                    })
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    func rejectRequest() {
        var transaction = self.transactionInfo
        var requestInfo:NSDictionary = ["transactionid": transaction["id"] as String!, "userid": self.curUser as String!, "tripOwnerName": transaction["tripOwnerName"] as String!, "locName": transaction["locName"] as String!]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlpinguserreject)
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
                    println("successfully sent rejectance of request")
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
    
    func delivered() {
        var transaction = self.transactionInfo
        var requestInfo:NSDictionary = ["transactionid": transaction["id"] as String!, "userid": self.curUser as String!, "tripOwnerName": transaction["tripOwnerName"] as String!, "locName": transaction["locName"] as String!, "itemsCost": self.bagCost.text!, "willPay": self.willPayLabel3.text!, "totalCost": self.totalCostLabel.text!]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlpinguserdelivered)
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
                    println("successfully sent rejectance of request")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayDeliveredResTransaction()
                    })
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()

    }

}