//
//  ViewController.swift
//  gofa
//
//  Created by Andrew Grant on 1/28/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var myRootRef: Firebase!
    var locationRef: Firebase!
    var myLocRef: Firebase!
    
    
    var newSignUp = false // if true, then register for remote notifications
    
    // node info 
    let urlkind = "gofa-app.com"
    var urlping: String!
    var urlunseennotif: String!
    var urllocations: String!
    var urlgetloclogo: String!
    var urlgettrips: String!
    var urladdlocation: String!
    
    var url: NSURL!
    
    // location manager
    var locManager: CLLocationManager!
    
    // array of location dictionaries
    var locations = [NSMutableDictionary]()
    var locationIndex = 0;
    
    // location info 
    var topLocKey: String!
    var topLocDict = [String: AnyObject]()
    var rightLocKey: String!
    var rightLocDict = [String: AnyObject]()
    var leftLocKey: String!
    var leftLocDict = [String: AnyObject]()
    
    // trip Notif UI elements 
    var topTripsNotif: UIImageView!
    var topCountLabel: UILabel!
    var rightTripsNotif: UIImageView!
    var rightCountLabel: UILabel!
    var leftTripsNotif: UIImageView!
    var leftCountLabel: UILabel!
    var topNotif = false
    var leftNotif = false
    var rightNotif = false
    
    // add location UI elements
    @IBOutlet weak var addLocation: UILabel!
    @IBOutlet weak var enterLocationTextField: UITextField!
    @IBOutlet weak var saveLocationButton: UIButton!
    
    var topHasLogo: Bool!
    var leftHasLogo: Bool!
    var rightHasLogo: Bool!
    
    
    // user info
    var authData: FAuthData!
    var curUser: String!
    var curUserName: String!
    var tripMode = false

    // transaction info (for segue to Notification VIew Controller)
    var transaction = [String: AnyObject]()
    
    
    @IBOutlet weak var buttonInterface: UIView!
    
    @IBOutlet weak var testLocationLabel: UILabel!
    
    @IBOutlet weak var topButton: OBShapedButton!
    @IBOutlet weak var leftButton: OBShapedButton!
    @IBOutlet weak var rightButton: OBShapedButton!
    
    @IBOutlet weak var postTripLabel: UILabel!
    @IBOutlet weak var modeButton: UIButton!
    
    
    @IBOutlet weak var userName: UIButton!
    
    func textFieldDidBeginEditing(textField: UITextField) {
        println("enabling")
        self.saveLocationButton.enabled = true
    }
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.enterLocationTextField.endEditing(true)
    }
    
    @IBAction func switchMode(sender: UIButton) {
        if tripMode == false {
            modeButton.setTitle("SHOP", forState: .Normal)
            tripMode = true
        } else {
            tripMode = false
            modeButton.setTitle("POST", forState: .Normal)
        }
    }
    
    @IBAction func didPressSave(sender: UIButton) {
        var requestInfo:NSDictionary = ["locName": self.enterLocationTextField.text]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urladdlocation)
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
                    println(feedback)
                    println("successfully added location")
                    var locInfo = feedback.mutableCopy() as NSMutableDictionary
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.enterLocationTextField.text = ""
                        if self.leftButton.enabled == false {
                            self.addNewLocationButton(locInfo, button: "left")
                        } else {
                            self.addLocation.hidden = true
                            self.enterLocationTextField.hidden = true
                            self.addLocation.hidden = true
                            self.saveLocationButton.hidden = true
                            self.addNewLocationButton(locInfo, button: "right")
                        }
        
                        //self.getLocations()
                    })
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    func addNewLocationButton(newLocInfo: NSMutableDictionary, button: String!) {
        self.locations.append(newLocInfo)
        if button == "left" {
            self.leftButton.enabled = true
            println(newLocInfo)
            self.leftLocKey = newLocInfo["id"] as String
            self.leftLocDict = [String: AnyObject]()
            self.leftLocDict["name"] = newLocInfo["name"]
            var ivLeftLocation = UILabel()
            self.leftButton.addSubview(ivLeftLocation)
            ivLeftLocation.text = newLocInfo["name"] as String!
            ivLeftLocation.font = UIFont(name: "Futura", size: 18)
            ivLeftLocation.textColor = UIColor.whiteColor()
            ivLeftLocation.sizeToFit()
            var superView = ivLeftLocation.superview!
            var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
            centerPoint.y = centerPoint.y - 5
            ivLeftLocation.center = centerPoint
        } else {
            self.rightButton.enabled = true
            self.rightLocKey = newLocInfo["id"] as String
            self.rightLocDict = [String: AnyObject]()
            self.rightLocDict["name"] = newLocInfo["name"]
            var ivRightLocation = UILabel()
            self.rightButton.addSubview(ivRightLocation)
            ivRightLocation.text = newLocInfo["name"] as String!
            ivRightLocation.font = UIFont(name: "Futura", size: 18)
            ivRightLocation.textColor = UIColor.whiteColor()
            ivRightLocation.sizeToFit()
            var superView = ivRightLocation.superview!
            var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
            centerPoint.y = centerPoint.y - 5
            ivRightLocation.center = centerPoint
        }
    }
    
    @IBAction func showDifferentLocations(sender: UIButton) {
        // remove current logos on screen
        var curTopIV = self.topButton.subviews[1] as UIImageView
        curTopIV.removeFromSuperview()
        if self.leftButton.enabled == true {
            if self.leftHasLogo == true {
                var curLeftIV = self.leftButton.subviews[1] as UIImageView
                curLeftIV.removeFromSuperview()
            } else {
                var curLeftLabel = self.leftButton.subviews[1] as UILabel
                curLeftLabel.removeFromSuperview()
            }
        }
        if self.rightButton.enabled == true {
            if self.rightHasLogo == true {
                var curRightIV = self.rightButton.subviews[1] as UIImageView
                curRightIV.removeFromSuperview()
            } else {
                var curRightLabel = self.rightButton.subviews[1] as UILabel
                curRightLabel.removeFromSuperview()
            }
        }
        displayNewLogos()
    }
    
    /// VENMO TESTS /////
    
    /*
    @IBAction func venmoMe(sender: UIButton) {
        Venmo.sharedInstance().sendPaymentTo("aggrant13@gmail.com", amount:4, note: "yup", audience: VENTransactionAudience.Private) { (transaction, success, error) -> Void in
            if (success) {
                println("success drew!")
            } else {
                println("venmo failed, error: " + error.localizedDescription)
            }
        }
    }
    */
    
    
    /// NODE TESTS /////
 
    @IBOutlet weak var serverResponse: UILabel!
    
    @IBAction func pingServer(sender: UIButton) {
        
        // set up request data
        var requestInfo:NSDictionary = ["userid": self.curUser]
        println(NSJSONSerialization.isValidJSONObject(requestInfo))
        
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
       
        println(requestData)
        
        let url = NSURL(string: urlping)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let pingTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("the data..")
                println(data)
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    self.serverResponse.text = "successfully sent to Brian"
                    println("successfully sent to Brian")
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
        
        pingTask.resume()
        
    }

   /* func showLocations() {
        // location id's
        var topLoc: String?
        var leftLoc: String?
        var rightLoc: String?
        
        // load image view information for new locations
        if (self.locationIndex >= locations.count) {
            self.locationIndex = 0
        }
        topLoc = self.locations[self.locationIndex++]
        getLocationLogo(topLoc!, buttonPos: "top")
        if (self.locationIndex < locations.count) {
            leftLoc = self.locations[self.locationIndex++]
            getLocationLogo(leftLoc!, buttonPos: "left")
        }
        if (self.locationIndex < locations.count) {
            rightLoc = self.locations[self.locationIndex++]
            getLocationLogo(rightLoc!, buttonPos: "right")
        }
    }
    
    func getLocationLogo(locationid: String!, buttonPos: String!) {
        var requestInfo:NSDictionary = ["locid": locationid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgetloclogo)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                println(feedback)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayLogo(feedback, buttonPos: buttonPos)
                })
            } else {
                println(error)
                println("nope")
            }
        })
        serverTask.resume()

        
    
    }
*/
    
    func displayNewLogos() {
        
        // location dictionaries
        var topLoc: NSDictionary
        var leftLoc: NSDictionary
        var rightLoc: NSDictionary
        
        var topLogoInfo: NSDictionary
        var leftLogoInfo: NSDictionary
        var rightLogoInfo: NSDictionary

        self.topLocDict = [String: AnyObject]()
        self.leftLocDict = [String: AnyObject]()
        self.rightLocDict = [String: AnyObject]()
        
        // load logo information for new locations
        println(self.locationIndex)
        println(locations.count)
        if (self.locationIndex >= locations.count) {
            self.locationIndex = 0
        }
        topLoc = self.locations[self.locationIndex++] as NSDictionary
        self.topLocKey = topLoc["id"] as String
        self.topLocDict = topLoc as [String: AnyObject]
        if let topLogoInfo = topLoc["logo"] as? NSDictionary {
            // display top(physically) Location
            var file = topLogoInfo["file"] as String
            var width = topLogoInfo["width"] as CGFloat
            var height = topLogoInfo["height"] as CGFloat
            println(file)
            var ivTopLocation = UIImageView(frame: CGRectMake(0, 0, width, height))
            self.topButton.addSubview(ivTopLocation)
            var iTopView = UIImage(named: file)
            ivTopLocation.image = iTopView
            var superView = ivTopLocation.superview!
            var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
            centerPoint.y = centerPoint.y - 5
            ivTopLocation.center = centerPoint
            self.topHasLogo = true
        } else {
            var topLocationLabel = UILabel()
            self.topButton.addSubview(topLocationLabel)
            topLocationLabel.text = topLoc["name"] as String!
            topLocationLabel.font = UIFont(name: "Futura", size: 18)
            topLocationLabel.textColor = UIColor.whiteColor()
            topLocationLabel.sizeToFit()
            var superView = topLocationLabel.superview!
            var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
            centerPoint.y = centerPoint.y - 5
            topLocationLabel.center = centerPoint
            self.topHasLogo = false
        }
        
        if (self.locationIndex < locations.count) {
            // display left Location
            leftLoc = self.locations[self.locationIndex++] as NSDictionary
            self.leftLocKey = leftLoc["id"] as String
            self.leftLocDict = leftLoc as [String: AnyObject]
            if let leftLogoInfo = leftLoc["logo"] as? NSDictionary {
                var file = leftLogoInfo["file"] as String
                var width = leftLogoInfo["width"] as CGFloat
                var height = leftLogoInfo["height"] as CGFloat
                var ivLeftLocation = UIImageView(frame: CGRectMake(0, 0, width, height))
                self.leftButton.addSubview(ivLeftLocation)
                var iLeftView = UIImage(named: file)
                ivLeftLocation.image = iLeftView
                var superView = ivLeftLocation.superview!
                var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
                centerPoint.y = centerPoint.y - 5
                ivLeftLocation.center = centerPoint
                self.leftHasLogo = true
            } else {
                var ivLeftLocation = UILabel()
                self.leftButton.addSubview(ivLeftLocation)
                ivLeftLocation.text = leftLoc["name"] as String!
                ivLeftLocation.font = UIFont(name: "Futura", size: 18)
                ivLeftLocation.textColor = UIColor.whiteColor()
                ivLeftLocation.sizeToFit()
                var superView = ivLeftLocation.superview!
                var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
                centerPoint.y = centerPoint.y - 5
                ivLeftLocation.center = centerPoint
                self.leftHasLogo = false
            }
            self.leftButton.enabled = true
        } else {
            self.leftHasLogo = false
            self.leftButton.enabled = false
        }
        
        if (self.locationIndex < locations.count) {
            // display right Location
            self.addLocation.hidden = true
            self.enterLocationTextField.hidden = true
            self.saveLocationButton.hidden = true
            rightLoc = self.locations[self.locationIndex++] as NSDictionary
            self.rightLocKey = rightLoc["id"] as String
            self.rightLocDict = rightLoc as [String: AnyObject]
            if let rightLogoInfo = rightLoc["logo"] as? NSDictionary {
                var file = rightLogoInfo["file"] as String
                var width = rightLogoInfo["width"] as CGFloat
                var height = rightLogoInfo["height"] as CGFloat
                var ivRightLocation =  UIImageView(frame: CGRectMake(0, 0, width, height))
                self.rightButton.addSubview(ivRightLocation)
                var iRightView = UIImage(named: file)
                ivRightLocation.image = iRightView
                var superView = ivRightLocation.superview!
                var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
                centerPoint.y = centerPoint.y - 5
                ivRightLocation.center = centerPoint
                self.rightHasLogo = true
            } else {
                var ivRightLocation = UILabel()
                self.rightButton.addSubview(ivRightLocation)
                ivRightLocation.text = rightLoc["name"] as String!
                ivRightLocation.font = UIFont(name: "Futura", size: 18)
                ivRightLocation.textColor = UIColor.whiteColor()
                ivRightLocation.sizeToFit()
                var superView = ivRightLocation.superview!
                var centerPoint = superView.convertPoint(superView.center, fromView: superView.superview)
                centerPoint.y = centerPoint.y - 5
                ivRightLocation.center = centerPoint
                self.rightHasLogo = false
            }
            self.rightButton.enabled = true
        } else {
            self.rightHasLogo = false
            self.rightButton.enabled = false
            // display Add Location SubView
            self.addLocation.hidden = false
            self.enterLocationTextField.hidden = false
            self.saveLocationButton.hidden = false
        }
        
        // display trips Notif for location
        displayTripNotifs()
        
    }

    func displayTripNotifs() {
        if self.topNotif == true {
            self.topNotif = false
            self.topTripsNotif.removeFromSuperview()
            self.topCountLabel.removeFromSuperview()
        }
        if self.rightNotif == true {
            self.rightNotif = false
            self.rightTripsNotif.removeFromSuperview()
            self.rightCountLabel.removeFromSuperview()
        }
        if self.leftNotif == true {
            self.leftNotif = false
            self.leftTripsNotif.removeFromSuperview()
            self.leftCountLabel.removeFromSuperview()
        }
        
        // display top Location's number of trips
        if let topTrips = self.topLocDict["trips"] as? NSDictionary {
            // get trips from firebase (ensures that old trips are removed)
            checkForTrips(self.topLocKey, button: "top")
        }
        
        if let rightTrips = self.rightLocDict["trips"] as? NSDictionary {
            checkForTrips(self.rightLocKey, button: "right")
        }
        
        if let leftTrips = self.leftLocDict["trips"] as? NSDictionary {
            checkForTrips(self.leftLocKey, button: "left")
        }
    }
    
    func displayTripNotifs2(numberOfTrips: Int!, button: String!) {
        var w = CGFloat(37)
        var h = CGFloat(33)
        var notifImage = UIImage(named: "notif")
        
        if (button == "top") {
            self.topNotif = true
            var topTripsCount = numberOfTrips
            self.topTripsNotif = UIImageView(frame: CGRectMake(CGFloat(64), CGFloat(14), w, h))
            self.topTripsNotif.image = notifImage
            self.buttonInterface.addSubview(self.topTripsNotif)
            self.topCountLabel = UILabel()
            self.buttonInterface.addSubview(topCountLabel)
            self.topCountLabel.text = String(topTripsCount)
            self.topCountLabel.font = UIFont(name: "Futura", size: 17)
            self.topCountLabel.textColor = UIColor.whiteColor()
            self.topCountLabel.sizeToFit()
            //var superView = topCountLabel.superview!
            self.topCountLabel.center = self.topTripsNotif.center
        }
        
        // display left Location's number of trips
        if (button == "left") {
            self.leftNotif = true
            var leftTripsCount = numberOfTrips
            self.leftTripsNotif = UIImageView(frame: CGRectMake(CGFloat(8), CGFloat(93), w, h))
            leftTripsNotif.image = notifImage
            self.buttonInterface.addSubview(leftTripsNotif)
            self.leftCountLabel = UILabel()
            self.buttonInterface.addSubview(leftCountLabel)
            leftCountLabel.text = String(leftTripsCount)
            leftCountLabel.font = UIFont(name: "Futura", size: 17)
            leftCountLabel.textColor = UIColor.whiteColor()
            leftCountLabel.sizeToFit()
            //var superView = topCountLabel.superview!
            leftCountLabel.center = leftTripsNotif.center
        }
        
        // display right Location's number of trips
        if (button == "right") {
            self.rightNotif = true
            var rightTripsCount = numberOfTrips
            self.rightTripsNotif = UIImageView(frame: CGRectMake(CGFloat(272), CGFloat(81), w, h))
            self.rightTripsNotif.image = notifImage
            self.buttonInterface.addSubview(self.rightTripsNotif)
            self.rightCountLabel = UILabel()
            self.buttonInterface.addSubview(rightCountLabel)
            rightCountLabel.text = String(rightTripsCount)
            rightCountLabel.font = UIFont(name: "Futura", size: 17)
            rightCountLabel.textColor = UIColor.whiteColor()
            rightCountLabel.sizeToFit()
            //var superView = topCountLabel.superview!
            rightCountLabel.center = rightTripsNotif.center
        }
    }
    
    func checkForTrips(locationid: String!, button: String!) {
        var requestInfo:NSDictionary = ["locationid": locationid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
        options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgettrips)
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
                println("successfully retrieved trips")
                var trips = feedback["trips"] as NSArray
                if trips.count > 0 {
                    //display trips
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayTripNotifs2(trips.count, button: button)
                    })
                }
            }
        } else {
            println(error)
            println("nope")
        }
        })
    
        serverTask.resume()
    }
    
    @IBAction func touchLocButton(sender: OBShapedButton) {
        if tripMode == true {
            let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let newTripVC:TripViewController = storyboard.instantiateViewControllerWithIdentifier("trip") as TripViewController
            newTripVC.curUser = self.curUser
            newTripVC.curUserName = self.curUserName
            
            var button = sender as OBShapedButton
            if button.tag == 0 {
                println(self.topLocKey)
                newTripVC.locationid = self.topLocKey
                println(self.topLocDict)
                newTripVC.locationDict = self.topLocDict
            } else if button.tag == 1 {
                newTripVC.locationid = self.rightLocKey
                newTripVC.locationDict = self.rightLocDict
            } else if button.tag == 2 {
                newTripVC.locationid = self.leftLocKey
                newTripVC.locationDict = self.leftLocDict
            }
            self.presentViewController(newTripVC, animated: false, completion: nil)
        } else {
            let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let locVC:LocationViewController = storyboard.instantiateViewControllerWithIdentifier("location") as LocationViewController
            locVC.authData = self.authData
            locVC.curUser = self.curUser
            locVC.curUserName = self.curUserName
            
            var button = sender as OBShapedButton
            if button.tag == 0 {
                locVC.locationid = self.topLocKey
                locVC.locationDict = self.topLocDict
            } else if button.tag == 1 {
                locVC.locationid = self.rightLocKey
                locVC.locationDict = self.rightLocDict
            } else if button.tag == 2 {
                locVC.locationid = self.leftLocKey
                locVC.locationDict = self.leftLocDict
            }
            self.presentViewController(locVC, animated: false, completion: nil)
        }
    }
   
  /*  @IBAction func topbutton(sender: UIButton) {
            let location = sender.titleLabel?.text
            locationRef = myRootRef.childByAppendingPath("locations/"+location!)
            locationRef.observeEventType(.Value, withBlock: {
                snapshot in
                self.locationSnapshot = snapshot
                println(snapshot)
                self.performSegueWithIdentifier("showLocation", sender:self)
            })
        
    }*/
    
    @IBAction func logout(sender: UIButton) {
        myRootRef.unauth()
        performSegueWithIdentifier("goto_login", sender: self)
    }
    
    func setupFirebase() {
        myRootRef = Firebase(url:"https://gofa.firebaseio.com/")
        
        locationRef = myRootRef.childByAppendingPath("locations/p01")
        locationRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.topLocKey = snapshot.key
            self.topLocDict = snapshot.value as Dictionary!
            //println(self.topLocSnap)
            //self.topLoc.text = self.topLocDict["name"] as? String
        })
        locationRef = myRootRef.childByAppendingPath("locations/p02")
        locationRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.rightLocKey = snapshot.key
            self.rightLocDict = snapshot.value as Dictionary!
           // println(self.rightLocSnap)
            //self.rightLoc.text = self.rightLocDict["name"] as? String
        })
        locationRef = myRootRef.childByAppendingPath("locations/p03")
        locationRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.leftLocKey = snapshot.key
            self.leftLocDict = snapshot.value as Dictionary!
            // println(self.rightLocSnap)
            //self.rightLoc.text = self.rightLocDict["name"] as? String
        })
    }
    
    
    override func viewDidAppear(animated: Bool) {
      //  registerRegions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enterLocationTextField.delegate = self
        
        self.urlping = "http://" + urlkind + "/ping"
        self.urlunseennotif = "http://" + urlkind + "/unseenNotif"
        self.urllocations = "http://" + urlkind + "/locations"
        self.urlgettrips = "http://" + urlkind + "/getTrips"
        self.urladdlocation = "http://" + urlkind + "/addLocation"
        getLocations()
        //showLocations()
    
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        //var myLocationManager = LocationManager.sharedInstance
        //myLocationManager.registerRegions()

        NSNotificationCenter.defaultCenter().addObserverForName("regionEntered", object: nil, queue: nil) { (notif) -> Void in
            println("got notif")
            var regionInfo = notif.userInfo as [String: String!]
            var regionName = regionInfo["region"] as String!
            let alertController = UIAlertController(title: "Hello!", message: "You entered a marked region " + regionName, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated:true, completion:nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("regionExited", object: nil, queue: nil, usingBlock: { (notif) -> Void in
            println("got notif")
            var regionInfo = notif.userInfo as [String: String!]
            var regionName = regionInfo["region"] as String!
            let alertController = UIAlertController(title: "Hello!", message: "You exited a marked region " + regionName, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated:true, completion:nil)
        })

    
        //var myLocationManager = LocationManager.sharedInstance
        //myLocationManager.registerRegions()
        
        //println(self.locManager)
        //if (self.locManager == nil) {
          //  self.initLocationManager()
        //}
        updateUI()
       
       /* myLocRef = Firebase(url:"https://gofa.firebaseio.com/locations/wawa")
        myLocRef.observeEventType(.Value, withBlock: {
            snapshot in
            println(snapshot)
            self.address = snapshot.value["address"] as? String
        })
*/

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
       // println(self.curUserName)
    }
    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "goto_trip" {
            var newTripVC = TripViewController()
            newTripVC = segue.destinationViewController as TripViewController
            newTripVC.authData = self.authData
            newTripVC.curUserName = self.curUserName
            
            var button = sender as OBShapedButton
            if button.tag == 0 {
                newTripVC.locationid = self.topLocKey
                newTripVC.locationDict = self.topLocDict
            } else if button.tag == 1 {
                newTripVC.locationid = self.rightLocKey
                newTripVC.locationDict = self.rightLocDict
            }
        }
        if segue.identifier == "goto_location" {
            var newLocVC = LocationViewController()
            newLocVC = segue.destinationViewController as LocationViewController
            newLocVC.authData = self.authData
            newLocVC.curUserName = self.curUserName
            
            var button = sender as OBShapedButton
            if button.tag == 0 {
                newLocVC.locationid = self.topLocKey
                newLocVC.locationDict = self.topLocDict
            } else if button.tag == 1 {
                println("correct")
                newLocVC.locationid = self.rightLocKey
                newLocVC.locationDict = self.rightLocDict
            }
            /*
            var locTripsRef = Firebase(url: "https://gofa.firebaseio.com/locations/\(newLocVC.location)/trips")
            locTripsRef.observeEventType(.Value, withBlock: {
                snapshot in
                var curTrips = snapshot.value as Dictionary?
                
            })*/
        }
        if segue.identifier == "goto_notif" {
                var newNotifVC = NotificationViewController()
                newNotifVC = segue.destinationViewController as NotificationViewController
                newNotifVC.transaction = self.transaction
                newNotifVC.curUser = self.curUser
        }
        if segue.identifier == "goto_transactions" {
                var newTransVC = TransactionViewController()
                newTransVC = segue.destinationViewController as TransactionViewController
                newTransVC.curUser = self.curUser
        }
        if segue.identifier == "goto_profile" {
                var newProfVC = ProfileViewController()
                newProfVC = segue.destinationViewController as ProfileViewController
                newProfVC.curUser = self.curUser
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //let ref = Firebase(url:"https://gofa.firebaseio.com/")
        
        myRootRef = Firebase(url:"https://gofa.firebaseio.com/")
        
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                self.authData = authData
                self.curUser = authData.uid
                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                delegate.curUser = self.curUser
                if self.curUser != nil {
                    self.checkForUnseenNotifs(self.curUser)
                }
                // register for Remote Notifications, update device token in Firebase for curUser id
                //UIApplication.sharedApplication().registerForRemoteNotifications()
                // for everett's phone
                var types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
                UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
                // get name of current user
                var usernameURL = "https://gofa.firebaseio.com/users/" + self.curUser + "/username"
                var usernameref = Firebase(url: usernameURL)
                usernameref.observeEventType(.Value, withBlock: { snapshot in
                    self.curUserName = snapshot.value as? String
                    println(self.curUserName)
                    self.userName.setTitle(self.curUserName, forState: .Normal)
                    },
                    withCancelBlock: { error in
                        println(error.description)
                })
            } else {
                // No user is logged in
                println("nouser")
                self.performSegueWithIdentifier("goto_login", sender:self)
            }
        })
    }
    
    
    func getLocations() {
        let url = NSURL(string: urllocations)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "GET"
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                for (locid, info) in feedback {
                    var info2 = info as NSDictionary
                    var locInfo = info2.mutableCopy() as NSMutableDictionary
                    locInfo["id"] = locid as String
                    self.locations.append(locInfo)
                }
                println(self.locations)
                println(self.locations.count)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayNewLogos()
                })
            
            } else {
                println(error)
                println("nope")
            }
        })
        serverTask.resume()
    }
    
    
    
    // contacts server to check for any unseened notification, and if there are any, sets the
    // notification controller as the root view controller
    func checkForUnseenNotifs(curUser: String!) {
        
        var requestInfo:NSDictionary = ["userid": curUser]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlunseennotif)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var pendingTransactions = feedback["pendingTrans"] as NSArray
                if pendingTransactions.count > 0 {
                    // present transactions view controller
                    self.performSegueWithIdentifier("goto_transactions", sender:self)
                } // else do nothing
               /* if  hasNotif == "true" {
                    self.transaction = feedback["transaction"] as Dictionary!
                    //there are unseen transactions, present notification view controller
                    self.performSegueWithIdentifier("goto_notif", sender:self)
                    //remoteNotif = remoteNotif as NSDictionary!
                    //notificationVC.notification = remoteNotif as NSDictionary
                }*/
            } else {
                println(error)
                println("nope")
            }
        })
        serverTask.resume()
    }
}





    /*
    func registerRegions() {
        // temporary, dtr: array that updates with closest 20 stores to user
        // dillsbury
        //18.030801, -76.771491
        // gate
       // 18.031568, -76.771533
        //gas station
        //18.031006, -76.773974
        //constant spring
        //18.040714, -76.795610
        
        var latitude:CLLocationDegrees = 18.040714
        var longitude:CLLocationDegrees = -76.795610
        var center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var radius:CLLocationDistance = CLLocationDistance(10.0)
        var identifier:String = "dillsbury"
        var overlay = MKCircle(centerCoordinate: center, radius: radius)
        registerRegionWithCircularOverlay(overlay, identifier: identifier)
    }
    
    func registerRegionWithCircularOverlay(overlay: MKCircle, identifier: String) {
        // If the overlay's radius is too large, registration fails automatically,
        // so clamp the radius to the max value.
        var radius = overlay.radius;
        if (radius > self.locManager.maximumRegionMonitoringDistance) {
            radius = self.locManager.maximumRegionMonitoringDistance;
        }
        // Create the geographic region to be monitored.
        var geoRegion = CLCircularRegion(center: overlay.coordinate, radius: radius, identifier: identifier)
        
        println(geoRegion)
        self.locManager.startMonitoringForRegion(geoRegion)
        self.locManager.requestStateForRegion(geoRegion)
        //println(self.locManager)
       // println("ok")
        println(self.locManager.monitoredRegions)
        if UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Available {
                println("all good")
        }
        //if CLAuthorizationStatue == CLAuthorizationStatus.AuthorizedAlways {
         //   println("all good again")
       // }
        
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLCircularRegion!) {
        println("in did determine state!")
        println(region)
        println(manager.location)
        var fromLoc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        var distance = manager.location.distanceFromLocation(fromLoc)
        println(distance)
        if (state == CLRegionState.Inside) {
            println("I'm home!")
        } else {
            println("keep trying")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println(locations)
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("you reach the bump")
        testLocationLabel.text = "you entered it man"
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        
    }
    
    // set up region boundaries
    
    func initLocationManager() {
        println("yup, view did load")
        self.locManager = CLLocationManager()
        locManager.delegate = self
        //locManager.locationServicesEnabled
        locManager.requestAlwaysAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        //locManager.startUpdatingLocation()
        registerRegions()
        //locManager.requestAlwaysAuthorization()
    }
*/


