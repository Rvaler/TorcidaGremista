//
//  MessagesTableViewCell.swift
//  TorcidaColorada
//
//  Created by Matheus Frozzi Alberton on 07/10/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var messageText: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
