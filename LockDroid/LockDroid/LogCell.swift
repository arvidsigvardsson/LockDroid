//
//  LogCell.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-05-23.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
    var logItem: LogItem? {
        didSet {
            refreshUI()
        }
    }
    
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var timeField: UILabel!
    @IBOutlet weak var didOpenSymbol: UILabel!
    
    func refreshUI() {
        nameField.text = logItem?.name
        dateField.text = logItem?.date
        timeField.text = logItem?.time
        if (logItem?.didOpen) == true {
            didOpenSymbol.textColor = UIColor.greenColor()
        } else {
            didOpenSymbol.textColor = UIColor.orangeColor()
        }
    }

}
