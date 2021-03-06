//
//  AppDelegate.swift
//  gofa
//
//  Created by Andrew Grant on 1/28/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var registered: Bool!
    var curUser: String!
    let urlstring = "http://gofa-app.com"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // get current user id (from ViewController)
        let vc = self.window!.rootViewController as ViewController
        self.curUser = vc.curUser as String?
        
        // set up venmo
        Venmo.startWithAppId("2324", secret: "qEeM3DxfKZBuqgUKJkGtDc346xMvpCDh", name: "Gofa")
        //Venmo.sharedInstance().defaultTransactionMethod = VENTransactionMethod.API

        
        // set up location manager
        var locMan = CLLocationManager()
        locMan.delegate = self
        self.startShowingLocationNotifications()

        var myLocationManager = LocationManager.sharedInstance
        myLocationManager.registerRegions()
        
        // if any remote notifications, handle them by configuring Notification Controller
        var remoteNotif: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
        if (remoteNotif != nil) {
            application.applicationIconBadgeNumber = 0
           /* let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let notificationVC:NotificationViewController = storyboard.instantiateViewControllerWithIdentifier("notificationVC") as NotificationViewController
            self.window!.rootViewController = notificationVC
            remoteNotif = remoteNotif as NSDictionary!
            notificationVC.notification = remoteNotif as NSDictionary
            if curUser != nil {
                notificationVC.curUser = curUser!
            }*/
        }
        /* else
        // if NO remote notifications, configure View Controller
        {
            configureViewController()
        }
        */
    
        //configureViewController()
        
        // register remote notifications
        
        // notification actions
        
        /*
        var notificationActionAccept: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionAccept.identifier = "ACCEPT_ID"
        notificationActionAccept.title = "Accept"
        notificationActionAccept.activationMode = UIUserNotificationActivationMode.Foreground
        
        var notificationActionReject: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionReject.identifier = "REJECT_ID"
        notificationActionReject.title = "I Can't, Sorry"
        notificationActionReject.activationMode = UIUserNotificationActivationMode.Background
        
        var notificationActionMoreInfo: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionMoreInfo.identifier = "MOREINFO_ID"
        notificationActionMoreInfo.title = "More Info"
        notificationActionMoreInfo.activationMode = UIUserNotificationActivationMode.Foreground
        
        var notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "REQUEST_CATEGORY"
        notificationCategory.setActions([notificationActionAccept, notificationActionMoreInfo, notificationActionReject], forContext: UIUserNotificationActionContext.Default)
        notificationCategory.setActions([notificationActionAccept, notificationActionMoreInfo], forContext: UIUserNotificationActionContext.Minimal)
        */
       
        
        
        // **********************
        //var types = UIUserNotificationType.Badge |
        // UIUserNotificationType.Sound | UIUserNotificationType.Alert
        //var mySettings = UIUserNotificationSettings(forTypes: types, categories: NSSet(array: [notificationCategory])
        //UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        // **********************
        
        
        // for Everett's Phone
        var types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
        //UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if (Venmo.sharedInstance().handleOpenURL(url)){
            return true
        }
        return false
    }
    
    /*
    func configureViewController() {
        var vc = self.window!.rootViewController as ViewController
        vc.setupFirebase()
    }
 */
    
    
    //brown: 40.346521 -74.657952
    func startShowingLocationNotifications() {
        var locNotification = UILocalNotification()
        locNotification.regionTriggersOnce = false
        
        var latitude:CLLocationDegrees = 40.346472
        var longitude:CLLocationDegrees = -74.660589
        var center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var radius:CLLocationDistance = CLLocationDistance(5.0)
        var identifier:String = "foulkelaughlin"
        
        locNotification.region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        println(locNotification.region)
        UIApplication.sharedApplication().scheduleLocalNotification(locNotification)
        println("SCHEDULING")
        println(UIApplication.sharedApplication().scheduledLocalNotifications)
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        println("success!!!!!!!!!!")
        var region = notification.region
        
        var regionInfo = ["region": region.identifier]
        NSNotificationCenter.defaultCenter().postNotificationName("regionEntered", object: nil, userInfo: regionInfo)
    }
           
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = 0
        if (application.applicationState == UIApplicationState.Active) {
            //do something (maybe alert?)
        } else {
            // app was brought from background to foreground
            /*
            let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let notificationVC:NotificationViewController = storyboard.instantiateViewControllerWithIdentifier("notificationVC") as NotificationViewController
            self.window!.rootViewController = notificationVC
            let remoteNotif = userInfo["payload"] as NSDictionary!
            notificationVC.notification = remoteNotif

            */
        }
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Delegation methods
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken devToken:NSData) {
        NSLog("deviceToken: %@", devToken)
        //let devTokenString = NSString(data: devToken, encoding: NSUTF8StringEncoding)
        //println(devTokenString)
        self.registered = true
        self.sendProviderDeviceToken(devToken) // custom method
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError err: NSError)
    {
        println("Error in registration for notifcations")
        NSLog("Error in registration. Error: ", err)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //let remoteNotif = userInfo["payload"] as NSDictionary!
        
        // Handle REQUEST notification's actions
       // if remoteNotif["category"] as? String == "REQUEST_CATEGORY" {
            //let action: UIUserNotificationAction = UIUserNotificationAction.fromRaw(identifier!)
       // }
    
    }
    
    func sendProviderDeviceToken(devToken: NSData) {
        var token = devToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        var requestInfo:NSDictionary = ["deviceToken": token, "userid": self.curUser]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: "http://gofa-app.com/saveDeviceToken")
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        //req.setValue(String(devToken.length), forHTTPHeaderField: "Content-Length")
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let postDevToken = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("Succesfully saved device token")
            } else {
                println("Error saving device token")
            }
        })
        
        postDevToken.resume()
    }
    

}

