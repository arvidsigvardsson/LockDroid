//
//  RfidTVC.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-04-28.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import UIKit

class RfidTVC: UITableViewController, UISplitViewControllerDelegate, NameCardVCDelegate {
    //    var refreshControl: UIRefreshControl?
    var editRow = 0
    
//    override func viewDidAppear(animated: Bool) {
//        if !loggedIn {
////            print("logged in: \(loggedIn)")
//            performSegueWithIdentifier("login segue", sender: self)
//        } else {
//            updateFromNetwork()
//            
//            // new data push notis
//            
//            
//        }
//    }
    
    @IBAction func refreshStarted(sender: UIRefreshControl) {
        updateFromNetwork()
    }
       
    @IBAction func openLockAction(sender: UIBarButtonItem) {
        makeOpenLockRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
//        updateFromNetwork()
    }
    
    func switchFlipped(sender: UISwitch) {
        let indexPath = tableView.indexPathForCell((sender.superview)!.superview as! RfidItemCell)
        rfidItemArray[indexPath!.row].accessGranted = sender.on
        makeAdminPostRequest(rfidItemArray)
    }
    
    
    
    var rfidItemArray: [RfidItem] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    func updateFromNetwork() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        makeAdminGetRequest() { array in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl?.endRefreshing()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let array = array {
                    self.rfidItemArray = array
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFromNetwork()
//                NSNotificationCenter.defaultCenter().addObserverForName("Change to card id data on server", object: nil, queue: nil) {
//            notification in
//            //            print("Notis mottagen")
//            self.updateFromNetwork()
            // gör ny request
//            makeLongPollRequest()
//        }
    }
        
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rfidItemArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rfid cell", forIndexPath: indexPath) as! RfidItemCell
        
        cell.rfidItem = rfidItemArray[indexPath.row]
        cell.accessSwitch.addTarget(self, action: #selector(RfidTVC.switchFlipped(_:)), forControlEvents: .ValueChanged)
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "login segue":
            (segue.destinationViewController as! LoginVC).parentVC = self
            break
        case "detail segue":
            let index = self.tableView.indexPathForSelectedRow?.row
            editRow = index!
//            let vc = segue.destinationViewController.childViewControllers.first as! NameCardVC
            let vc = segue.destinationViewController as! NameCardVC
            let item = rfidItemArray[index!]
            vc.rfidItem = item
            vc.masterVC = self
            vc.delegate = self
        default:
            break
        }
        
       
     }
    
    func cardStateChanged(rfidItem: RfidItem) {
        print("rad vald: \(self.tableView.indexPathForSelectedRow?.row)")
        rfidItemArray[editRow] = rfidItem
        makeAdminPostRequest(rfidItemArray)
    }
}












