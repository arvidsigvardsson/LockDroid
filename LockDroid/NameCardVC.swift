//
//  NameCardVC.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-04-28.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import UIKit

protocol NameCardVCDelegate {
    func cardStateChanged(rfidItem: RfidItem)
}

class NameCardVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var accessSwitch: UISwitch!
    
    @IBAction func switchFlipped(sender: UISwitch) {
        rfidItem?.accessGranted = sender.on
        delegate?.cardStateChanged(rfidItem!)
    }
    
    var rfidItem: RfidItem?
    var masterVC: RfidTVC?
    var delegate: NameCardVCDelegate?
    
    func refreshUI() {
        if let item = rfidItem {
            idLabel.text = item.id
            accessSwitch.setOn(item.accessGranted, animated: false)
            if let name = item.cardName {
                nameField.text = name
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("Textfield should return")
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("did end editing")
        if nameField.text == "" {
            rfidItem?.cardName = nil
        } else {
            rfidItem?.cardName = nameField.text
        }
        delegate!.cardStateChanged(rfidItem!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    
//    override func didMoveToParentViewController(parent: UIViewController?) {
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        print("Går bakåt till \(unwindVC)")

//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
