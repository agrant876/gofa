//
//  LoginViewController.swift
//  gofa
//
//  Created by Andrew Grant on 1/30/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import UIKit
import Foundation


class LoginViewController: UIViewController {

    var authData:FAuthData!
   
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func signinTapped(sender: UIButton) {
        var email:NSString = txtEmail.text
        var password:NSString = txtPassword.text
        
        let ref = Firebase(url: "https://gofa.firebaseio.com")
        ref.authUser(email, password: password) {
            error, authData in
            if error != nil {
                // an error occured while attempting login
            } else {
                // user is logged in, check authData for data
                println("logged in")
                self.authData = authData
                self.performSegueWithIdentifier("goto_homepage", sender: self)
            
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_homepage" {
            var HomeVC = ViewController()
            println(self.authData.uid)
            HomeVC = segue.destinationViewController as ViewController
            HomeVC.authData = self.authData
        }
    }
    
}