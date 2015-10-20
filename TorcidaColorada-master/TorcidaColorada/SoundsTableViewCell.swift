//
//  SoundsTableViewCell.swift
//  TorcidaColorada
//
//  Created by Moisés Pio on 8/22/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit

class SoundsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIImageView!
    @IBOutlet weak var audioName: UILabel!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var buttonPlayAndPause: UIButton!
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonSubmit2: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
