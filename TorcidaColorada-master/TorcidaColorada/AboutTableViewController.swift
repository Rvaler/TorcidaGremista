//
//  AboutTableViewController.swift
//  TorcidaColorada
//
//  Created by Moisés Pio on 8/22/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logout(sender: AnyObject) {
        UserManager.logOut()
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
}