//
//  NotificationViewController.swift
//  gofa
//
//  Created by Andrew Grant on 3/18/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit


class NotificationViewController: UIViewController {

    
    var notification: NSDictionary? //for when app is launched from notification
    var transaction: NSDictionary? //for when app is launched, or brought to foreground with app icon

    var requestInfo: NSDictionary!
    var curUser: String?
    
    
    let urlpinguseraccept = "http://localhost:3000/pingUserAccept"
    let urlgettransinfo = "http://localhost:3000/getTransactionInfo"
    let urldefertrans = "http://localhost:3000/deferTransaction"
    
    @IBOutlet weak var customerName: UIButton!
    @IBAction func viewCustomer(sender: UIButton) {
        
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var bagContentsLabel: UILabel!
    
    
    // segue to View Controller, and change status of transaction to deferred
    @IBAction func goToHome(sender: UIButton) {
        deferTransaction()
    }
    
    @IBAction func acceptPressed(sender: OBShapedButton) {
        pingUserAccept()
    }
    
    func deferTransaction() {
        var transaction = self.transaction!
        var transactionid = transaction["id"] as String!
        var userid = transaction["customer"] as String!
        var reqInfo:NSDictionary = ["transactionid": transactionid, "userid": userid]
        var reqData = NSJSONSerialization.dataWithJSONObject(reqInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urldefertrans)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = reqData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    //self.pingResponse.text = "successfully sent"
                    println("successfully updated transaction status")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("goto_home", sender: self)
                        }
                    )
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
        

    }
    
    func pingUserAccept() {
        var acceptInfo: NSDictionary! = requestInfo
        acceptInfo.setValue(curUser, forKey: "senderid")
        var acceptData = NSJSONSerialization.dataWithJSONObject(acceptInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        
        let url = NSURL(string: urlpinguseraccept)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = acceptData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    //self.pingResponse.text = "successfully sent"
                    println("successfully sent acceptance of request to" + (self.requestInfo["userid"] as String!))
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if notification != nil {
            //app launched from notification
            //get relevant info for transaction from notification dictionary
            //self.requestInfo = notification["requestInfo"] as NSDictionary!
            customerName.titleLabel?.text = notification!["messageFrom"] as String!
            locationLabel.text = notification!["location"] as String!
            bagContentsLabel.text = notification!["bag"] as String!
        } else {
            //app not launched from notification
            //get relevant info for transaction from server
            getTransactionInfo()
        }
    }
    
    func getTransactionInfo() {
        var transaction = self.transaction!
        var transactionid = transaction["id"] as String!
        var reqInfo:NSDictionary = ["transactionid": transactionid]
        var reqData = NSJSONSerialization.dataWithJSONObject(reqInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgettransinfo)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = reqData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.customerName.titleLabel!.text = feedback["userName"] as String!
                    self.locationLabel.text = feedback["locName"] as String!
                    //self.bagContentsLabel.text = notification!["bag"] as String!
                })
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()

    }
    
}

