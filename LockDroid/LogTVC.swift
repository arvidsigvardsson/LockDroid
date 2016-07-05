//
//  LogTVC.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-05-23.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import UIKit

class LogTVC: UITableViewController {

    var logs: [LogItem] = [] {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        updateFromNetwork()
    }
    
    func updateFromNetwork() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        makeLogGetRequest { [weak self] (result) in
            switch result {
            case .Success(let array):
                //                print(array)
                self?.logs = array
            case .Failure(_): break
            }
            
            self?.refreshControl?.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        updateFromNetwork()
    }
    
    @IBAction func openAction(sender: UIBarButtonItem) {
        makeOpenLockRequest()
        updateFromNetwork()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return logs.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("log cell", forIndexPath: indexPath) as! LogCell

//        let li = LogItem(name: "Arvid", date: "12/12/2015", time: "00:00:00", didOpen: false)
        cell.logItem = logs[logs.count - indexPath.row - 1]
        return cell
    }
    

    

}
