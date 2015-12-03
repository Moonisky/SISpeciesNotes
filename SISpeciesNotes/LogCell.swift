//
//  LogCell.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-30.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: Life Circle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
