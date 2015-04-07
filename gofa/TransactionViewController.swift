//
//  TransactionViewController.swift
//  gofa
//
//  Created by Andrew Grant on 3/26/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit

class TransactionViewController: UIViewController {
    
    var curUser: String!
    var transactions: Array<NSDictionary> = []
    var reqCount = 0
    var resCount = 0
    var transIndex = 0
    
    let urlkind = "gofa-app.com"
    var urlgettransactions: String!
    var urlgettransactioninfo: String!
    var urlpinguseraccept: String!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noTransactions: UILabel!
    @IBOutlet weak var noTrips: UILabel!
    
    @IBOutlet weak var reqTransactionsView: UIView!
    
    func touchTransactionTab(sender: OBShapedButton) {
        var transTab = sender as OBShapedButton
        var transactionInfo = transactions[transTab.tag] as [String: AnyObject]
        var status = transactionInfo["transStatus"] as String
        if status == "delivered" {
            for view in transTab.subviews as [UIView] {
                if let payButton = view as? UIButton {
                    performSegueWithIdentifier("goto_pay", sender: payButton)
                }
            }
        } else {
            performSegueWithIdentifier("goto_transactioninfo", sender: sender)
        }
    }

    func touchTransactionResponseTab(sender: OBShapedButton) {
        performSegueWithIdentifier("goto_transactionresponseinfo", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_transactioninfo" {
            var transactionInfoVC = TransactionInfoViewController()
            transactionInfoVC = segue.destinationViewController as TransactionInfoViewController
            var transTab = sender as OBShapedButton
            var transactionInfo = transactions[transTab.tag] as [String: AnyObject]
            var status = transactionInfo["transStatus"] as String
            transactionInfoVC.status = status
            transactionInfoVC.curUser = self.curUser
            transactionInfoVC.transactionInfo = transactionInfo
        }
        if segue.identifier == "goto_transactionresponseinfo" {
            var transactionInfoVC = TransactionInfoResponseViewController()
            transactionInfoVC = segue.destinationViewController as TransactionInfoResponseViewController
            var transTab = sender as OBShapedButton
            var transactionInfo = transactions[transTab.tag] as [String: AnyObject]
            var status = transactionInfo["transStatus"] as String
            println(transactionInfo)
            transactionInfoVC.status = status
            transactionInfoVC.curUser = self.curUser
            transactionInfoVC.transactionInfo = transactionInfo
        }
        if segue.identifier == "goto_pay" {
            var payVC = PayViewController()
            payVC = segue.destinationViewController as PayViewController
            var payButton = sender as UIButton
            var transTab = payButton.superview as OBShapedButton
            var transactionInfo = transactions[transTab.tag] as [String: AnyObject]
            payVC.transactionInfo = transactionInfo
            payVC.curUser = self.curUser
        }
    }

    @IBAction func backToHome(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let VC:ViewController = storyboard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(VC, animated: false, completion: nil)
    }
    
    // present controller to pay for transaction
    func goToPay(sender: UIButton) {
        performSegueWithIdentifier("goto_pay", sender: sender)
    }
    
    func acceptRequest(sender: UIButton) {
        var transTab = sender.superview as OBShapedButton
        var transaction = transactions[transTab.tag]
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
                        var tabAccepted = UIImage(named: "tabgreen")
                        transTab.setImage(tabAccepted, forState: UIControlState.Normal)
                        sender.hidden = true
                        var acceptedLabel = UILabel()
                        transTab.addSubview(acceptedLabel)
                        acceptedLabel.text = "Accepted!"
                        acceptedLabel.font = UIFont(name: "Futura", size: 11)
                        acceptedLabel.textColor = UIColor.greenColor()
                        acceptedLabel.sizeToFit()
                        var tabSize = transTab.frame.size
                        acceptedLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
                    })
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
        self.activityIndicator.startAnimating()
        
        self.urlgettransactions = "http://" + urlkind + "/getTransactions"
        self.urlpinguseraccept = "http://" + urlkind + "/pingUserAccept"
        self.urlgettransactioninfo = "http://" + urlkind + "/getTransactionInfo"
        
        getTransactions(self.curUser)
       /* var reqTransactionsView = UIView(frame: CGRectMake(10, 100, 278, 180))
        reqTransactionsView.backgroundColor = UIColor.blueColor()
        reqTransactionsView.center.x = self.view.center.x
        reqTransactionsView.alpha = 0.2
        self.view.addSubview(reqTransactionsView)
        //var testLabel = UILabel(frame: CGRE, reqTransactionsView.center, 40 40)
        //testLabel.text = "Center"
        //testLabel..*/
        
        /*
        var transactionTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab.frame = CGRectMake(5, 320, 278, 45)
        transactionTab.center.x = self.view.center.x
        var transTab = UIImage(named: "tab")
        transactionTab.setImage(transTab, forState: UIControlState.Normal)
        transactionTab.alpha = 0.8
        self.view.addSubview(transactionTab)

        var transactionTab2 = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab2.frame = CGRectMake(5, 100, 278, 45)
        transactionTab2.center.x = self.view.center.x
        transactionTab2.setImage(transTab, forState: UIControlState.Normal)
        transactionTab2.alpha = 0.8
        self.view.addSubview(transactionTab2)
        
        
        var transactionTab3 = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab3.frame = CGRectMake(5, 200, 278, 45)
        transactionTab3.center.x = self.view.center.x
        transactionTab3.setImage(transTab, forState: UIControlState.Normal)
        transactionTab3.alpha = 0.8
        self.view.addSubview(transactionTab3)
*/

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    // gets the transactions of 'user' from Firebase, and then calls getTransactionInfo() for all the transactions
    func getTransactions(user: String!) {
        self.urlgettransactions = "http://" + urlkind + "/getTransactions"
        var requestInfo:NSDictionary = ["userid": user]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgettransactions)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    if let test1 = feedback["reqTransactions"] as? NSDictionary {
                        var transactions = feedback["reqTransactions"] as NSDictionary!
                        for (transactionid, transactionstatus) in transactions {
                            self.getTransactionInfo(transactionid as String, request: true)
                        }
                    }
                    if let test2 = feedback["resTransactions"] as? NSDictionary {
                        var transactions = feedback["resTransactions"] as NSDictionary!
                        for (transactionid, transactionstatus) in transactions {
                            self.getTransactionInfo(transactionid as String, request: false)
                        }
                    }
                } else {
                    println("stats is empty")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    })
                }
            } else {
                println(error)
                println("nope")
                // fail gracefully
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                })
            }
        })
        serverTask.resume()
    }
    
    // gets transaction info of transactionid, updates these transactions depending on toa and status, and calls displayReqTransactionTab or displayResTransactionTab for all the relevant transactions (that weren't deleted in server code)
    func getTransactionInfo(transactionid: String!, request: Bool) {
        self.urlgettransactioninfo = "http://" + urlkind + "/getTransactionInfo"
        var requestInfo:NSDictionary = ["transactionid": transactionid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgettransactioninfo)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var status = feedback["status"] as String!
                if (status == "success") {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // present tab with transaction info, do not present paid transactions
                        var transactionInfo = feedback.mutableCopy() as NSMutableDictionary
                        var status = transactionInfo["transStatus"] as String
                        if status != "paid" {
                            if request == true {
                                self.displayReqTransactionTab(transactionInfo)
                                self.noTransactions.hidden = true
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.hidden = true
                            } else {
                                self.displayResTransactionTab(transactionInfo)
                                self.noTrips.hidden = true
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.hidden = true
                            }
                        } else  {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.hidden = true
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    })
                }
            } else {
                println(error)
                println("nope")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                })
            }
        })
        serverTask.resume()

    }
    
    func displayReqTransactionTab(transactionInfo: NSMutableDictionary!) {
        // update transactions array
        transactionInfo["request"] = true
        transactions.append(transactionInfo)
        var transactionTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab.tag = self.transIndex
        self.transIndex = self.transIndex + 1
        
        var yheight = reqCount*50 + 100 // tabs have 5 units between each other
        transactionTab.frame = CGRectMake(10, CGFloat(yheight), 278, 45)
        transactionTab.center.x = self.view.center.x
        var tabSize = transactionTab.frame.size
        var status = transactionInfo["transStatus"] as String
        if status == "pending" {
            var transTab = UIImage(named: "tab")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            var statusLabel = UILabel()
            transactionTab.addSubview(statusLabel)
            statusLabel.text = "P"
            statusLabel.font = UIFont(name: "Futura", size: 11)
            statusLabel.textColor = UIColor.whiteColor()
            statusLabel.sizeToFit()
            statusLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        }
        if status == "accepted" {
            var transTab = UIImage(named: "tabgreen")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            var statusLabel = UILabel()
            transactionTab.addSubview(statusLabel)
            statusLabel.text = "Accepted"
            statusLabel.font = UIFont(name: "Futura", size: 11)
            statusLabel.textColor = UIColor.greenColor()
            statusLabel.sizeToFit()
            statusLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        }
        if status == "delivered" {
            var transTab = UIImage(named: "tabgreen")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            var payButton   = UIButton.buttonWithType(UIButtonType.System) as UIButton
            payButton.frame = CGRectMake(5, 5, 35, 25)
            transactionTab.addSubview(payButton)
            payButton.setTitle("Pay", forState: UIControlState.Normal)
            payButton.titleLabel?.font = UIFont(name: "Futura", size: 11)
            payButton.titleLabel?.sizeToFit()
            payButton.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
            // acceptButton.titleLabel?.textColor = UIColor.whiteColor()
            payButton.backgroundColor = UIColor.whiteColor()
            payButton.layer.cornerRadius = 5
            payButton.addTarget(self, action: "goToPay:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        transactionTab.addTarget(self, action: "touchTransactionTab:", forControlEvents: UIControlEvents.TouchUpInside)
        var locLabel = UILabel()
        transactionTab.addSubview(locLabel)
        var locName = transactionInfo["locName"] as String!
        locName.replaceRange(locName.startIndex...locName.startIndex, with: String(locName[locName.startIndex]).capitalizedString)
        locLabel.text = locName
        locLabel.font = UIFont(name: "Futura", size: 11)
        locLabel.textColor = UIColor.whiteColor()
        locLabel.sizeToFit()
        locLabel.center = CGPoint(x: tabSize.width/2 - tabSize.width*(3/8), y: tabSize.height/2)
        var nameLabel = UILabel()
        transactionTab.addSubview(nameLabel)
        nameLabel.text = transactionInfo["tripOwnerName"] as String!
        nameLabel.font = UIFont(name: "Futura", size: 11)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: tabSize.width/2, y: tabSize.height/2)
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true

        reqCount = reqCount + 1
    }
    
    func displayResTransactionTab(transactionInfo: NSMutableDictionary!) {
        // update transactions array
        transactionInfo["request"] = false
        transactions.append(transactionInfo)
        var transactionTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab.tag = self.transIndex
        self.transIndex = self.transIndex + 1
        
        var yheight = resCount*50 + 320 // tabs have 5 units between each other
        transactionTab.frame = CGRectMake(10, CGFloat(yheight), 278, 45)
        transactionTab.center.x = self.view.center.x
        var tabSize = transactionTab.frame.size
        var status = transactionInfo["transStatus"] as String
        if status == "pending" || status == "deferred" {
            println(status)
            var transTab = UIImage(named: "tab")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            var acceptButton   = UIButton.buttonWithType(UIButtonType.System) as UIButton
            acceptButton.frame = CGRectMake(5, 5, 50, 35)
            transactionTab.addSubview(acceptButton)
            acceptButton.setTitle("Accept", forState: UIControlState.Normal)
            acceptButton.titleLabel?.font = UIFont(name: "Futura", size: 11)
            acceptButton.titleLabel?.sizeToFit()
            acceptButton.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
           // acceptButton.titleLabel?.textColor = UIColor.whiteColor()
            acceptButton.backgroundColor = UIColor.whiteColor()
            acceptButton.layer.cornerRadius = 5
            acceptButton.addTarget(self, action: "acceptRequest:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        if status == "accepted" {
            var transTab = UIImage(named: "tabgreen")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            var statusLabel = UILabel()
            transactionTab.addSubview(statusLabel)
            statusLabel.text = "Accepted"
            statusLabel.font = UIFont(name: "Futura", size: 11)
            statusLabel.textColor = UIColor.greenColor()
            statusLabel.sizeToFit()
            statusLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        }
        if status == "delivered" {
            var transTab = UIImage(named: "tabgreen")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            var statusLabel = UILabel()
            transactionTab.addSubview(statusLabel)
            statusLabel.text = "Delivered"
            statusLabel.font = UIFont(name: "Futura", size: 11)
            statusLabel.textColor = UIColor.greenColor()
            statusLabel.sizeToFit()
            statusLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        }
        
        transactionTab.addTarget(self, action: "touchTransactionResponseTab:", forControlEvents: UIControlEvents.TouchUpInside)
        var locLabel = UILabel()
        transactionTab.addSubview(locLabel)
        var locName = transactionInfo["locName"] as String!
        locName.replaceRange(locName.startIndex...locName.startIndex, with: String(locName[locName.startIndex]).capitalizedString)
        locLabel.text = locName
        locLabel.font = UIFont(name: "Futura", size: 11)
        locLabel.textColor = UIColor.whiteColor()
        locLabel.sizeToFit()
        locLabel.center = CGPoint(x: tabSize.width/2 - tabSize.width*(3/8), y: tabSize.height/2)
        var nameLabel = UILabel()
        transactionTab.addSubview(nameLabel)
        nameLabel.text = transactionInfo["custName"] as String!
        nameLabel.font = UIFont(name: "Futura", size: 11)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: tabSize.width/2, y: tabSize.height/2)
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true


        resCount = resCount + 1
    }
    
}