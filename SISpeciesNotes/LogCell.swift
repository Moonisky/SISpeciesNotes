//
//  LogCell.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-30.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit

/// 记录单元格
class LogCell: UITableViewCell {
    
    // MARK: 属性
    
    var model: LogModel! {
        didSet {
            titleLabel.text = model.title
            iconImageView.image = model.iconImage
            subtitleLabel.text = model.subtitle
            distanceLabel.text = "\(model.distance)" + "km"
        }
    }
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: Life Circle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
