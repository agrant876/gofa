//
//  AddressBookViewController.swift
//  gofa
//
//  Created by Andrew Grant on 4/9/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit
import AddressBookUI

class AddressBookViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    override func viewDidLoad() {
        var picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        self.presentViewController(picker, animated: true) { () -> Void in
            
        }
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecordRef!) -> Bool {

            self.displayPerson(person)
            peoplePicker.dismissViewControllerAnimated(true, completion: nil)
            
            return false;
    }

    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {
        return false
    }
    
    
    func displayPerson(person: ABRecordRef!)
    {

        var name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as String
        self.firstName.text = name
    
        var phone: String?
        var unmanagedPhoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty)
        
        let phoneNumbers: ABMultiValueRef =
        Unmanaged.fromOpaque(unmanagedPhoneNumbers.toOpaque()).takeUnretainedValue()
            as NSObject as ABMultiValueRef
        
        if (ABMultiValueGetCount(phoneNumbers) > 0
            ) {
            phone = ABMultiValueCopyValueAtIndex(phoneNumbers, 0).takeRetainedValue() as? String
        } else {
            phone = "[None]"
        }
        self.phoneNumber.text = phone
        
       // CFRelease(phoneNumbers);
    }


}
