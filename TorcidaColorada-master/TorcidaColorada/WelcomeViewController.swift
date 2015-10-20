//
//  WelcomeViewController.swift
//  TorcidaColorada
//
//  Created by Moisés Pio on 8/22/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class WelcomeViewController: UIViewController {
    @IBOutlet weak var facebookButton: UIButton!
    
    var permissions = ["public_profile", "email", "user_friends"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButton.layer.cornerRadius = 2
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
//        self.activityIndicator.startAnimating()

        let userControl = UserManager()

        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in

            if let loggedUser = user as? UserManager {
                if loggedUser.isNew {
                    print("User signed up and logged in through Facebook!")
                    userControl.returnUserData(loggedUser, callback: { (error) -> () in
                        if(error == nil) {
                            print("Dados alterados com sucesso")
                        }
                    })
                } else {
                    print("User logged in Facebook!")
                }
                NSNotificationCenter.defaultCenter().postNotificationName("login", object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
            if error != nil {
                print(error);
            }
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
