//
//  MessagesViewController.swift
//  TorcidaColorada
//
//  Created by Matheus Frozzi Alberton on 07/10/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDataSource {
    var isRoot : Bool = true
    var refreshControl:UIRefreshControl!
    var messages : [Messages] = []

    var friends : [UserManager] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if(UserManager.currentUser() != nil) {
            loadMessages()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadMessages", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)

        self.tableView.tableFooterView = UIView();
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadMessages", name: "login", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadByPushNotification", name: "openSpot", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadByPushNotification() {
        let tabBarController = self.navigationController as! MainViewController
        if let pushType = tabBarController.pushType {
            if(pushType == "searchios9") {
                print("oi")
//                self.userSelected = tabBarController.pushPhotoId
//                self.performSegueWithIdentifier("selectSound", sender: nil)
            }
            
            tabBarController.pushPhotoId = nil
            tabBarController.pushType = nil
        }
    }

    override func viewWillAppear(animated: Bool) {
        if isRoot {
            self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("view2") as UIViewController, animated: false)
        } else {
            let currentInstallation = PFInstallation.currentInstallation()
            
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }

        if(UserManager.currentUser() == nil) {
            self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("view2") as UIViewController, animated: false)
        } else {
            //            loadData()
            PushManager.associateDeviceWithCurrentUser()
        }
    }

    @IBAction func backFromMessages(segue:UIStoryboardSegue) {
    }

    @IBAction func showFriends(sender: AnyObject) {
        self.performSegueWithIdentifier("goFriends", sender: nil)
    }

    func loadMessages() {
        let messages = Messages()
        
        messages.getMessages { (allMessages, error) -> () in
            if error == nil {
                self.messages = allMessages
                self.updateTableView()
            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesTableViewCell
        
        let message = messages[indexPath.row]

        if let user = message.user {
            if let sound = message.sound {
                let first = user.name
                let second = " enviou: " + sound.name!
                let string = NSMutableAttributedString(string: first + second)
                
                let labelFont = UIFont(name: "HelveticaNeue-Bold", size: 15)

                string.addAttribute(NSFontAttributeName, value: labelFont!, range: NSMakeRange(0, first.characters.count))
                string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSMakeRange(first.characters.count, second.characters.count))
                cell.messageText.attributedText = string
                
//                cell.messageText.text = user.name + " enviou: " + sound.name!
                let url = NSURL(string: user.photo!.url!)
                cell.userPhoto.setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

                cell.userPhoto.layer.cornerRadius = cell.userPhoto.frame.size.width / 2
                cell.userPhoto.clipsToBounds = true
            }
        }

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func updateTableView() {
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "goFriends") {
            let rVC : FriendsViewController = segue.destinationViewController as! FriendsViewController
            rVC.friends = self.friends
            
            rVC.backFromMessages = true
        }
    }

}
