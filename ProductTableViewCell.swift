//
//  ProductTableViewCell.swift
//  E-chase
//
//  Created by Parth Saxena on 1/8/17.
//  Copyright © 2017 Parth Saxena. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.productImageView.alpha = 0
        self.titleLabel.alpha = 0
        self.priceLabel.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
