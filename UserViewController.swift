//
//  UserViewController.swift
//  gofa
//
//  Created by Andrew Grant on 2/3/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit

class UserViewController: UIViewController {
    
    var userKey: FAuthData!
    
    var hasFirstName:Bool = false
    var hasLastName:Bool = false
    var hasUserName:Bool = false
    
    var firstName: String!
    var lastName: String!
    var userName: String!
    var street: String?
    var area: String?
    var state: String?
    
    var buttonColor: UIColor?
    
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var userNameTxt: UITextField!
    

    @IBOutlet weak var streetTxt: UITextField!
    @IBOutlet weak var areaTxt: UITextField!
    @IBOutlet weak var stateTxt: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func firstNameEntered(sender: UITextField) {
        hasFirstName = true
        firstName = firstNameTxt.text
        if hasLastName == true && hasUserName == true {
            submitButton.backgroundColor = buttonColor
            submitButton.enabled = true
        }
    }
    
    @IBAction func lastNameEntered(sender: UITextField) {
        hasLastName = true
        lastName = lastNameTxt.text
        if hasFirstName == true && hasUserName == true {
            submitButton.backgroundColor = buttonColor
            submitButton.enabled = true
        }
    }
    
    @IBAction func userNameEntered(sender: UITextField) {
        hasUserName = true
        userName = userNameTxt.text
        if hasFirstName == true && hasLastName == true {
            submitButton.backgroundColor = buttonColor
            submitButton.enabled = true
        }
    }
    
    
    
    @IBAction func submitUserInfo(sender: UIButton){
        User.updateUserInfo(userKey.uid, userInfo: ["firstname": firstName, "lastname": lastName, "username": userName])
        // need to display error or success depending on return value
        performSegueWithIdentifier("goto_homepage", sender: self)
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonColor = submitButton.backgroundColor
        submitButton.enabled = false
        submitButton.backgroundColor = .grayColor()
//        updateUI()
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_homepage" {
            var HomeVC = ViewController()
            HomeVC = segue.destinationViewController as ViewController
            HomeVC.authData = self.userKey
        }
    }
    
}