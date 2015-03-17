//
//  User.swift
//  gofa
//
//  Created by Andrew Grant on 2/3/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class User {

    /*var authId: FAuthData!
    var provider: String!
    var email: String!
    var firstName: String!
    var lastName: String!
    var userName: String!
    var address: String?
    var trip: Trip?
    var transactions = [Transaction]()
    var rootref: Firebase!
    var userref: Firebase!
    */
    
    
    // adds user's email and password to Database
    class func newUser(newAuth: FAuthData!)
    {
        var ref = Firebase(url: "https://gofa.firebaseio.com")

        // enter new users info into firebase
        let newUser = [
            "provider": newAuth.provider,
            "email": newAuth.providerData["email"] as? NSString as? String
        ]
        // enter user provider and email into Firebase
        ref.childByAppendingPath("users")
            .childByAppendingPath(newAuth.uid).setValue(newUser)
        return
    }
    
    // updates userId's account information (name, username, address etc)
    class func updateUserInfo(userId: String, userInfo: Dictionary<String, String>)
    {
        var userURL = "https://gofa.firebaseio.com/users/" + userId
        var userref = Firebase(url: userURL)
        userref.updateChildValues(userInfo)
        // need to do call back and return error or success
        return
    }
    
    // return the userName of User with userId
    class func userName(userId: String) -> String
    {
        
        var userName = ""

        /*let queue:dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)*/
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var usernameURL = "https://gofa.firebaseio.com/users/" + userId + "/username"
            var usernameref = Firebase(url: usernameURL)
            usernameref.observeEventType(.Value, withBlock: { snapshot in
                userName = snapshot.value as String
                println(userName)
                
                }, withCancelBlock: { error in
                    println(error.description)
            })
        })
        return userName
    }
    
}