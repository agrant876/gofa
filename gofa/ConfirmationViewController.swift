//
//  ConfirmationViewController.swift
//  gofa
//
//  Created by Andrew Grant on 4/3/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation


class ConfirmationViewController: UIViewController, UITextViewDelegate {

    var locationid: String!
    var locationDict = [String: AnyObject]()
    var locationName: String!
    var locationAddress:String!
    
    var authData: FAuthData!
    var curUserName: String!
    var curUser: String!
    
    var bagContents: String!
    
    var tripid: String!
    var tripInfo: NSDictionary!
    
    let urlkind = "gofa-app.com"
    var urlpinguser: String!
    var urlgetbag: String!
   
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tripOwnerLabel: UILabel!
    @IBOutlet weak var bagEmptyLabel: UILabel!
    @IBOutlet weak var addressEmptyLabel: UILabel!
    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var bagContentsTextView: UITextView!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmed: UILabel!
    @IBOutlet weak var backToLocationLabel: UIButton!
   
    @IBAction func confirmTransaction(sender: UIButton) {
        pingUser(self.tripid)
    }
    
    @IBAction func backToLocation(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let locVC:LocationViewController = storyboard.instantiateViewControllerWithIdentifier("location") as LocationViewController
        locVC.curUser = self.curUser
        locVC.curUserName = self.curUserName
        locVC.locationid = self.locationid
        locVC.locationDict = self.locationDict
        self.presentViewController(locVC, animated: false, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        bagContentsTextView.endEditing(true)
        addressTextView.endEditing(true)
    }
    
    func textViewDidBeginEditing(textview: UITextView) {
        self.addressEmptyLabel.hidden = true
        self.bagEmptyLabel.hidden = true
        self.confirmButton.enabled = true
    }
    
    func textViewDidChange(bagTextView: UITextView) {
        self.bagEmptyLabel.hidden = (countElements(self.bagContentsTextView.text) > 0);
    }
    
    func updateConfirmation(success: Bool) {
        confirmButton.hidden = true
        if (success) {
            confirmed.hidden = false
            //backToLocationLabel.titleLabel?.font.fontWithSize(13)
            //backToLocationLabel.titleLabel?.text = "Make more requests!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlpinguser = "http://" + urlkind + "/pingUser"
        self.urlgetbag = "http://" + urlkind + "/getbag"

        getBag()
        
        bagContentsTextView.delegate = self
        addressTextView.delegate = self
        bagContentsTextView.layer.cornerRadius = 8
        addressTextView.layer.cornerRadius = 8
        confirmButton.layer.borderWidth = 1
        confirmButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        locationName.replaceRange(locationName.startIndex...locationName.startIndex, with: String(locationName[locationName.startIndex]).capitalizedString)
        locationLabel.text = locationName
        tripOwnerLabel.text = tripInfo["userName"] as String!
        
        if (bagContents != nil) {
            bagContentsTextView.text = bagContents
            bagEmptyLabel.hidden = true
            confirmButton.enabled = true
        }
        
        tripOwnerLabel.sizeToFit()
        
    }
    
    // Server Call Methods
    func pingUser(tripid: String!) {
        
        // set up request
        var requestInfo:NSDictionary = ["custid": self.curUser, "custName": self.curUserName, "tripid": tripid, "bagContents": self.bagContentsTextView.text, "userLoc": self.addressTextView.text, "locName": self.locationLabel.text as String!]
        //println(NSJSONSerialization.isValidJSONObject(requestInfo))
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        
        let url = NSURL(string: urlpinguser)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (status == "success") {
                        //self.pingResponse.text = "successfully sent"
                        println("successfully sent to Brian")
                        self.updateConfirmation(true)
                    } else {
                        println("unsuccessfully sent to Brian")
                        self.updateConfirmation(false)
                    }
                })
            } else {
                println(error)
                println("unsuccessfully sent to Brian")
                self.updateConfirmation(false)
            }
        })
        
        serverTask.resume()
    }

    func getBag() {
        var bagInfo = ["userid": self.curUser, "locationid": self.locationid]
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
                println(feedback["contents"])
                self.bagContents = feedback["contents"] as? String
                println("successfully got bag")
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.updateBagUI()
                })
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    func updateBagUI() {
        if (self.bagContents != nil) {
            self.bagContentsTextView.text = self.bagContents
            self.bagEmptyLabel.hidden = true
            self.confirmButton.enabled = true
        } else {
            self.bagEmptyLabel.hidden = false
        }
    }
    
}