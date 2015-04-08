//
//  PayViewController.swift
//  gofa
//
//  Created by Andrew Grant on 4/5/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class PayViewController: UIViewController
{
    var curUser: String!
    var transactionInfo = [String: AnyObject]()
    var tripInfo = [String: AnyObject]()
    var status: String! // status of request (pending/deferred, accepted, completed, paid)

    let urlkind = "gofa-app.com"
    var urlgetbag: String!
    var urlpinguserpaid: String!
    
    @IBOutlet weak var tripOwnerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bagContentsTextView: UITextView!
    @IBOutlet weak var feeTextField: UITextField!
    @IBOutlet weak var payButton: OBShapedButton!
    @IBOutlet weak var payLabel: UILabel!
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        feeTextField.endEditing(true)
    }
    
    @IBAction func backToTransactions(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let transVC:TransactionViewController = storyboard.instantiateViewControllerWithIdentifier("transactions") as TransactionViewController
        transVC.curUser = self.curUser
        self.presentViewController(transVC, animated: false, completion: nil)
    }
    
    @IBAction func payVenmo(sender: OBShapedButton) {
        println(feeTextField.text)
        var amountToPay = NSNumberFormatter().numberFromString(feeTextField.text)
        println(amountToPay)
           // toInt()! * 100
        var email = transactionInfo["tripOwnerEmail"] as String
        Venmo.sharedInstance().sendPaymentTo(email, amount: UInt(amountToPay!.integerValue * 100), note: "Thanks!", audience: VENTransactionAudience.Private) { (transaction, success, error) -> Void in
            if (success) {
                println("successfully paid")
                self.successfullyPaid()
                
                /*self.payLabel.text = "Paid!"
                self.payLabel.textColor = UIColor.greenColor()
                self.payButton.hidden = true
                    let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                    let VC:ViewController = storyboard.instantiateViewControllerWithIdentifier("home") as ViewController
                    self.presentViewController(VC, animated: false, completion: nil)
            */
            } else {
                println("venmo failed, error: " + error.localizedDescription)
            }
        }

    }

    func successfullyPaid() {
        var transaction = self.transactionInfo
        var requestInfo:NSDictionary = ["transactionid": transaction["id"] as String!, "customerid": self.curUser as String!, "tripOwnerId": transaction["tripOwnerId"] as String!, "custName": transaction["custName"] as String!, "locName": transaction["locName"] as String!]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlpinguserpaid)
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
                    println("successfully paid " + (requestInfo["tripOwnerId"] as String!))
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.payButton.hidden = true
                        self.payLabel.text = "Paid!"
                        self.payLabel.textColor = UIColor.greenColor()
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
        self.urlgetbag = "http://" + urlkind + "/getbag"
        self.urlpinguserpaid = "http://" + urlkind + "/pingUserPaid"
        self.tripOwnerLabel.text = self.transactionInfo["tripOwnerName"] as String!
        self.locationLabel.text = self.transactionInfo["locName"] as String!
        getBag()
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


}