//
//  RfidItemCell.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-04-28.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import UIKit

class RfidItemCell: UITableViewCell {
    var rfidItem: RfidItem? {
        didSet {
            refreshUI()
        }
    }
    
    @IBOutlet weak var accessSwitch: UISwitch!
    @IBOutlet weak var idNameLabel: UILabel!
    func refreshUI() {
        if let item = rfidItem {
            idNameLabel.text = item.cardName ?? item.id
            accessSwitch.setOn(item.accessGranted, animated: false)
        }
    }
}
