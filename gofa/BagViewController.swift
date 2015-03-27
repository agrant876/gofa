//
//  BagViewController.swift
//  gofa
//
//  Created by Andrew Grant on 2/15/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore

class BagViewController: UIViewController, UITextViewDelegate {

    var authData: FAuthData!
    var curUser: String!
    var curUserName: String!
    var location: String!
    var locationName: String!
    var bagContents: String?
    
    let urlbag = "http://localhost:3000/bag"
    let urlgetbag = "http://localhost:3000/getbag"
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        bagTextView.endEditing(true)
    }
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var locationLabel: UILabel!
   // @IBOutlet weak var listTextView: UITextView!
    
    @IBOutlet weak var bagTextView: UITextView!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bagTextView.delegate = self
        self.curUser = authData.uid
        self.placeholderLabel.hidden = true
        self.activityIndicator.startAnimating()
        //locationLabel.text = locationName
        updateUI()
        //display bag contents, if any
        getBag()
    
        //NSLog(locationName)
    }
    
    func textViewDidBeginEditing(bagTextView: UITextView) {
        self.placeholderLabel.hidden = true
    }
    
    func textViewDidChange(bagTextView: UITextView) {
        self.placeholderLabel.hidden = (countElements(self.bagTextView.text) > 0);
    }

    
    @IBAction func saveBag(sender: UIButton) {
        var bagContents = bagTextView.text;
        var bagInfo = ["contents": bagContents, "userid": self.curUser, "locationid": self.location]
        
        println(NSJSONSerialization.isValidJSONObject(bagInfo))
        
        var bagData = NSJSONSerialization.dataWithJSONObject(bagInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        
        let url = NSURL(string: urlbag)
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
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    //self.serverResponse.text = "successfully sent to Brian"
                    println("successfully saved bag")
                }
                //var resArray: NSDictionary! =  NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as NSDictionary
                //println(resArray)
                //var textResponse = resArray["text"] as String!
                //self.serverResponse.text = textResponse
                //println(resArray["text"] as String!)
                //println(response.description)
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
        
    }
    
    func getBag() {
        
        var bagInfo = ["userid": self.curUser, "locationid": self.location]
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
            self.bagTextView.text = bagContents
            self.placeholderLabel.hidden = true
        } else {
            self.placeholderLabel.hidden = false
        }
        self.activityIndicator.stopAnimating()
    }
    
    func updateUI() {

        locationLabel.text = locationName
      
        self.bagTextView.layer.cornerRadius = 8
        
        
        
        /* var colorSpace = CGColorSpaceCreateDeviceRGB()
        var blue = CGColorCreate(colorSpace, [0.0, 0.0, 0.0, 0.5])
        listTextView.layer.borderColor = blue
        listTextView.layer.borderWidth = 2.0
        listTextView.layer.cornerRadius = 5
        listTextView.clipsToBounds = true
*/
        /*

    [textView.layer setBorderWidth:2.0]
    
    //The rounded corner part, where you specify your view's corner radius:
    textView.layer.cornerRadius = 5;
    textView.clipsToBounds = YES;
*/
    }
    
}