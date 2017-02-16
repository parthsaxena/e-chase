//
//  OrderTableViewCell.swift
//  E-chase
//
//  Created by Parth Saxena on 2/14/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.timeLabel.alpha = 0
        self.statusLabel.alpha = 0
        self.itemsLabel.alpha = 0
        
        UIView.animate(withDuration: 0.5) { 
            self.timeLabel.alpha = 1
            self.statusLabel.alpha = 1
            self.itemsLabel.alpha = 1
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
