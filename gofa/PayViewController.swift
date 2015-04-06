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

    let urlgetbag = "http://localhost:3000/getbag"
    
    @IBOutlet weak var tripOwnerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bagContentsTextView: UITextView!
    @IBOutlet weak var feeTextField: UITextField!
    
    @IBAction func backToTransactions(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let transVC:TransactionViewController = storyboard.instantiateViewControllerWithIdentifier("transactions") as TransactionViewController
        transVC.curUser = self.curUser
        transVC.getTransactions(self.curUser)
        self.presentViewController(transVC, animated: false, completion: nil)
    }
    
    @IBAction func payVenmo(sender: OBShapedButton) {
        var amountToPay = feeTextField.text.toInt()! * 100
        var email = transactionInfo["tripOwnerEmail"] as String
        Venmo.sharedInstance().sendPaymentTo(email, amount: UInt(amountToPay), note: "", audience: VENTransactionAudience.Private) { (transaction, success, error) -> Void in
            if (success) {
                println("success drew!")
            } else {
                println("venmo failed, error: " + error.localizedDescription)
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripOwnerLabel.text = self.transactionInfo["tripOwnerName"] as String!
        locationLabel.text = self.transactionInfo["locName"] as String!
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