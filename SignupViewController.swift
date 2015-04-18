//
//  SignupViewController.swift
//  gofa
//
//  Created by Andrew Grant on 1/30/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: UIViewController {
    
    var newAuthData: FAuthData!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordConfirm: UITextField!
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func signupTapped(sender: UIButton) {
    
       /* var firstName:NSString = txtFirstName.text*/
        var email:NSString = txtEmail.text
        var password:NSString = txtPassword.text
        var confirmPassword:NSString = txtPasswordConfirm.text
    
        if (password != confirmPassword) {
            println("Error: confirmation password does not match password")
        } else {
            let ref = Firebase(url: "https://gofa.firebaseio.com")
            ref.createUser(email, password: password) {
                error, authData in
                if error != nil {
                    println(error)
                    // an error occured while registering user
                } else {
                    // user is registered, sign in user
                    ref.authUser(email, password: password) {
                        error, authData in
                        if error != nil {
                            println("error signing in user")
                            println(error)
                            // an error occured while attempting login
                        } else {
                            // user is logged in, check authData for data
                            println("logged in")
                
                            // create new User
                            User.newUser(authData)
                            self.newAuthData = authData
                            self.performSegueWithIdentifier("goto_userinfo", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_userinfo" {
            var userVC = UserViewController()
            userVC = segue.destinationViewController as UserViewController
            userVC.userKey = self.newAuthData
        }
    }

    
    
    @IBAction func gotoLogin(sender: UIButton) {
    }
}