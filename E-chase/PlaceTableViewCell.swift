//
//  PlaceTableViewCell.swift
//  E-chase
//
//  Created by Parth Saxena on 1/8/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var placeOpenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.placeImageView.alpha = 0
        self.placeTitleLabel.alpha = 0
        self.placeOpenLabel.alpha = 0
        
        self.placeImageView.layer.masksToBounds = true
        self.placeImageView.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
