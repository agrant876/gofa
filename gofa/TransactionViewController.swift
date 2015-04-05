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
    
    let urlgettransactions = "http://localhost:3000/getTransactions"
    let urlgettransactioninfo = "http://localhost:3000/getTransactionInfo"

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noTransactions: UILabel!
    @IBOutlet weak var noTrips: UILabel!
    
    @IBOutlet weak var reqTransactionsView: UIView!
    
    
    
    func touchTransactionTab(sender: OBShapedButton) {
        performSegueWithIdentifier("goto_transactioninfo", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_transactioninfo" {
            var transactionInfoVC = TransactionInfoViewController()
            transactionInfoVC = segue.destinationViewController as TransactionInfoViewController
            var transTab = sender as OBShapedButton
            transactionInfoVC.curUser = self.curUser
            transactionInfoVC.transactionInfo = transactions[transTab.tag] as [String: AnyObject]
        }
    }

    @IBAction func backToHome(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let VC:ViewController = storyboard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(VC, animated: false, completion: nil)
    }
    
    func acceptRequest(sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
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

        //getTransactions(self.curUser)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
 
    }
    
    
    // gets the transactions of 'user' from Firebase, and then calls getTransactionInfo() for all the transactions
    func getTransactions(user: String!) {
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
        println("get*****************")
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
                println("the data..")
                println(data)
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // present tab with transaction info
                        if request == true {
                            self.displayReqTransactionTab(feedback.mutableCopy() as NSMutableDictionary)
                            self.noTransactions.hidden = true
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.hidden = true
                        } else {
                            self.displayResTransactionTab(feedback.mutableCopy() as NSMutableDictionary)
                            self.noTrips.hidden = true
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
        var status = transactionInfo["transStatus"] as String
        if status == "pending" {
            var transTab = UIImage(named: "tab")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            transactionTab.addTarget(self, action: "touchTransactionTab:", forControlEvents: UIControlEvents.TouchUpInside)
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
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
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
        var status = transactionInfo["transStatus"] as String
        if status == "pending" || status == "deferred" {
            println(status)
            var transTab = UIImage(named: "tab")
            transactionTab.setImage(transTab, forState: UIControlState.Normal)
            transactionTab.alpha = 0.8
            self.view.addSubview(transactionTab)
            transactionTab.addTarget(self, action: "touchTransactionTab:", forControlEvents: UIControlEvents.TouchUpInside)
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
            println(acceptButton)
            println(transactionTab)
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
        resCount = resCount + 1
    }
    
}