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
    var curUserName: String!
    var location: String!
    var locationName: String!

    @IBOutlet weak var locationLabel: UILabel!
   // @IBOutlet weak var listTextView: UITextView!
    
    @IBOutlet weak var bagTextView: UITextView!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bagTextView.delegate = self
        NSLog(locationName)
        updateUI()
        locationLabel.text = locationName
    }
    
    func textViewDidBeginEditing(bagTextView: UITextView) {
        self.placeholderLabel.hidden = true
    }
    
    func textViewDidChange(bagTextView: UITextView) {
        self.placeholderLabel.hidden = (countElements(self.bagTextView.text) > 0);
    }

    


    
    func updateUI() {

        locationLabel.text = locationName
      
        self.bagTextView.layer.cornerRadius = 8;
        
        
        
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