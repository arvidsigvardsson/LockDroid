//
//  LoginVC.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-04-29.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    var parentVC: RfidTVC?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let user = defaults.stringForKey("username")
        let pass = defaults.stringForKey("password")
        
        if let user = user, pass = pass {
            usernameField.text = user
            passwordField.text = pass
        }
    }
    @IBAction func loginButton(sender: UIButton) {
        print("button action")
        attemptLogin()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            attemptLogin()
        }
        return true
    }
    
    func attemptLogin() {
        makeLoginRequest(usernameField.text!, password: passwordField.text!) {
            statusCode, responseText, error in
            print("statuskod: \(statusCode)")
            print("svar: \(responseText)")
            let defaults = NSUserDefaults.standardUserDefaults()
            
            dispatch_async(dispatch_get_main_queue()) {
                if statusCode == 200 {
                    self.performSegueWithIdentifier("login segue", sender: self)
                    defaults.setValue(self.usernameField.text!, forKey: "username")
                    defaults.setValue(self.passwordField.text, forKey: "password")
                    //                self.parentVC?.loggedIn = true
                    //                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    defaults.setValue("", forKey: "username")
                    defaults.setValue("", forKey: "password")
                    self.errorMessageLabel.hidden = false
                }
            }
        }
    }
}
