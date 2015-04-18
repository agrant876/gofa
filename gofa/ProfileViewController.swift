//
//  ProfileViewController.swift
//  gofa
//
//  Created by Andrew Grant on 4/8/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class ProfileViewController: UIViewController {
    
    var curUser: String!

    var curTrips: Array<NSDictionary> = []
    var paidReqTransactions: Array<NSDictionary> = []
    var paidResTransactions: Array<NSDictionary> = []
    
    let urlkind = "gofa-app.com"
    var urlgetpaidtransactions: String!
    var urlgetpaidtransactioninfo: String!
    var urlgetusercurtrips: String!
    var urlgettripinfo: String!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var myTripsbutton: UIButton!
    @IBOutlet weak var myRequestsbutton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var currentTripsScrollV: UIScrollView!
    @IBOutlet weak var transactionHistScrollV: UIScrollView!
    @IBOutlet weak var noTripsLabel: UILabel!
    
    @IBAction func viewMyTrips(sender: UIButton) {
        loadTransactions(false)
        self.myTripsbutton.titleLabel?.textColor = UIColor.darkGrayColor()
        self.myRequestsbutton.titleLabel?.textColor = UIColor.lightGrayColor()
    }
    
    @IBAction func viewMyRequests(sender: UIButton) {
        loadTransactions(true)
        self.myTripsbutton.titleLabel?.textColor = UIColor.lightGrayColor()
        self.myRequestsbutton.titleLabel?.textColor = UIColor.darkGrayColor()
    }
    
    
    @IBAction func logout(sender: UIButton) {
        var myRootRef = Firebase(url:"https://gofa.firebaseio.com/")
        myRootRef.unauth()
        performSegueWithIdentifier("goto_login", sender: self)
    }
    
    func loadTrips() {
        if self.curTrips.count == 0 {
            self.activityIndicator.stopAnimating()
            self.noTripsLabel.hidden = false
        }
        for var index = 0; index < self.curTrips.count; index++ {
            self.noTripsLabel.hidden = true
            var trip = self.curTrips[index]
            displayTripTab(trip, index: index)
        }
    }
    
    func displayTripTab(trip: NSDictionary, index: Int) {
        var tripTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        tripTab.tag = index
        var yheight = index*50 + 5 // tabs have 5 units between each other
        tripTab.frame = CGRectMake(0, CGFloat(yheight), 278, 45)
        var tabSize = tripTab.frame.size
        var tabImage = UIImage(named: "tab")
        tripTab.setImage(tabImage, forState: UIControlState.Normal)
        tripTab.alpha = 0.8
        var locLabel = UILabel()
        tripTab.addSubview(locLabel)
        locLabel.text = trip["locName"] as String!
        locLabel.font = UIFont(name: "Futura", size: 11)
        locLabel.textColor = UIColor.whiteColor()
        locLabel.sizeToFit()
        locLabel.center = CGPoint(x: tabSize.width/2 - tabSize.width*(3/10), y: tabSize.height/2)
        var date = NSDate(timeIntervalSince1970: (trip["toa"] as NSTimeInterval))
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var dateLabel = UILabel()
        tripTab.addSubview(dateLabel)
        dateLabel.text = dateFormatter.stringFromDate(date)
        dateLabel.font = UIFont(name: "Futura", size: 11)
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.sizeToFit()
        dateLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        self.currentTripsScrollV.addSubview(tripTab)
        var superView = tripTab.superview!
        var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
        tripTab.center.x = centerPoint.x
        self.currentTripsScrollV.contentSize = CGSize(width: CGFloat(290), height: CGFloat((index+1)*50))
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func loadTransactions(requests: Bool) {
        let subviews = self.transactionHistScrollV.subviews
        for subview in subviews{
            subview.removeFromSuperview()
        }
        if requests == false {
            // display response transactions
            if self.paidResTransactions.count == 0 {
                self.activityIndicator.stopAnimating()
                self.emptyLabel.hidden = false
            }
            for var index = 0; index < self.paidResTransactions.count; index++ {
                println(self.paidResTransactions.count)
                self.emptyLabel.hidden = true
                var transaction = self.paidResTransactions[index]
                println(transaction)
                displayTab(transaction, index: index)
            }
        } else {
            // display requests transactions
            if self.paidReqTransactions.count == 0 {
                self.activityIndicator.stopAnimating()
                self.emptyLabel.hidden = false
            }
            for var index = 0; index < self.paidReqTransactions.count; index++ {
                self.emptyLabel.hidden = true
                var transaction = self.paidReqTransactions[index]
                displayTab(transaction, index: index)
            }
        }
    }
    
    func displayTab(transactionInfo: NSDictionary, index: Int) {
        var transactionTab = OBShapedButton.buttonWithType(UIButtonType.Custom) as OBShapedButton
        transactionTab.tag = index
        var yheight = index*50 + 5 // tabs have 5 units between each other
        transactionTab.frame = CGRectMake(0, CGFloat(yheight), 278, 45)
        var tabSize = transactionTab.frame.size
        var transTab = UIImage(named: "tab")
        transactionTab.setImage(transTab, forState: UIControlState.Normal)
        transactionTab.alpha = 0.8
        self.transactionHistScrollV.addSubview(transactionTab)
        var superView = transactionTab.superview!
        var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
        transactionTab.center.x = centerPoint.x
        //self.view.addSubview(transactionTab)
        println("in displaytab")
        var date = NSDate(timeIntervalSince1970: (transactionInfo["toa"] as NSTimeInterval))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        var dateLabel = UILabel()
        transactionTab.addSubview(dateLabel)
        dateLabel.text = dateFormatter.stringFromDate(date)
        dateLabel.font = UIFont(name: "Futura", size: 11)
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.sizeToFit()
        dateLabel.center = CGPoint(x: tabSize.width/2 + tabSize.width*(3/8), y: tabSize.height/2)
        //transactionTab.addTarget(self, action: "touchTransactionTab:", forControlEvents: UIControlEvents.TouchUpInside)
        var locLabel = UILabel()
        transactionTab.addSubview(locLabel)
        var locName = transactionInfo["locName"] as String!
        locName.replaceRange(locName.startIndex...locName.startIndex, with: String(locName[locName.startIndex]).capitalizedString)
        locLabel.text = locName
        locLabel.font = UIFont(name: "Futura", size: 11)
        locLabel.textColor = UIColor.whiteColor()
        locLabel.sizeToFit()
        locLabel.center = CGPoint(x: tabSize.width/2 - tabSize.width*(3/10), y: tabSize.height/2)
        var nameLabel = UILabel()
        transactionTab.addSubview(nameLabel)
        nameLabel.text = transactionInfo["custName"] as String!
        nameLabel.font = UIFont(name: "Futura", size: 11)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: tabSize.width/2, y: tabSize.height/2)
        self.transactionHistScrollV.contentSize = CGSize(width: CGFloat(290), height: CGFloat((index+1)*50))
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.urlgetpaidtransactions = "http://" + urlkind + "/getPaidTransactions"
        self.urlgetpaidtransactioninfo = "http://" + urlkind + "/getPaidTransactionInfo"
        self.urlgetusercurtrips = "http://" + urlkind + "/getUserCurTrips"
        self.urlgettripinfo = "http://" + urlkind + "/getTripInfo"
        
        getUserCurTrips()
        getPaidTransactions()
    }
    
    
    func getUserCurTrips() {
        var requestInfo:NSDictionary = ["userid": self.curUser]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgetusercurtrips)
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
                if (status == "yes") {
                    var trips = feedback["trips"] as NSDictionary
                    for (tripid, toa) in trips {
                        self.getTripInfo(tripid as String)
                    }
                } else {
                    
                    // no trips
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
    
    func getTripInfo(tripid: String!) {
        self.urlgettripinfo = "http://" + urlkind + "/getTripInfo"
        println("**********************")
        println(tripid)
        var requestInfo:NSDictionary = ["tripid": tripid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgettripinfo)
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
                // var status = feedback["status"] as String!
                //if (status == "success") {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var tripInfo = feedback["tripInfo"] as NSDictionary
                    self.curTrips.append(tripInfo)
                    // display current trips
                    println("ingettripinfo")
                    self.loadTrips()
                })
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

    func getPaidTransactions() {
        var requestInfo:NSDictionary = ["userid": self.curUser]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgetpaidtransactions)
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
                    if let test1 = feedback["reqTransactions"] as? NSDictionary {
                        var transactions = feedback["reqTransactions"] as NSDictionary!
                        for (transactionid, bagContents) in transactions {
                            self.getPaidTransactionInfo(transactionid as String, request: true)
                        
                        }
                    }
                    if let test2 = feedback["resTransactions"] as? NSDictionary {
                        var transactions = feedback["resTransactions"] as NSDictionary!
                        for (transactionid, bagContents) in transactions {
                            self.getPaidTransactionInfo(transactionid as String, request: false)
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
    
    func getPaidTransactionInfo(transactionid: String!, request: Bool) {
        self.urlgetpaidtransactioninfo = "http://" + urlkind + "/getPaidTransactionInfo"
        println(transactionid)
        var requestInfo:NSDictionary = ["transactionid": transactionid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgetpaidtransactioninfo)
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
               // var status = feedback["status"] as String!
                //if (status == "success") {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var transactionInfo = feedback.mutableCopy() as NSMutableDictionary
                    if request == true {
                        self.paidReqTransactions.append(transactionInfo)
                        println("correct")
                    } else {
                        self.paidResTransactions.append(transactionInfo)
                    }
                    // display paid trips
                    println("ingetpaidtransinfo")
                    self.loadTransactions(false)
                })
                //}
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
    
}