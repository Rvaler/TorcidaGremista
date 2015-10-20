//
//  FriendsViewController.swift
//  TorcidaColorada
//
//  Created by Moisés Pio on 8/22/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class FriendsViewController: UIViewController {
    var friends : [UserManager] = []
    var userSelected : String?
    var refreshControl:UIRefreshControl!
    var backFromMessages:Bool = false

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var successMessageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messagesButton: UIBarButtonItem!

    var sendMessage: Bool = false

    @IBOutlet weak var sorryMessage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "login", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addCoreSpoth", name: "login", object: nil)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadByPushNotification", name: "openSpot", object: nil)

        if backFromMessages {
            self.sorryMessage.hidden = true
            self.activityIndicator.stopAnimating()

            backFromMessages = false
        } else {
            if(UserManager.currentUser() != nil) {
                loadData()
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        if(UserManager.currentUser() == nil) {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        } else {
//            loadData()
            let newButton = MIBadgeButton()
            newButton.frame = CGRectMake(0, 0, 45, 30)
            newButton.setImage(UIImage(named: "chat-icon"), forState: .Normal)
            newButton.addTarget(self, action: "showMessages:", forControlEvents: .TouchUpInside)
            //        newButton.backgroundColor = UIColor.blackColor()
            
            let currentInstallation = PFInstallation.currentInstallation()
            
            if currentInstallation.badge > 0 {
                newButton.badgeString = String(currentInstallation.badge)
                newButton.badgeEdgeInsets = UIEdgeInsetsMake(21, 0, 0, 22.5)
                newButton.badgeTextColor = UIColor.redColor()
                newButton.badgeBackgroundColor = UIColor.whiteColor()

                messagesButton.customView = newButton
            }
            
            PushManager.associateDeviceWithCurrentUser()
        }

//        let tabBarController = self.navigationController as! MainViewController
//        if (tabBarController.pushPhotoId != nil) {
//            self.loadByPushNotification()
//        }
    }

    func showSuccessMessage() {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hideSuccessMessage"), userInfo: nil, repeats: false)
        successMessageTopConstraint.constant = 0

        UIView.animateWithDuration(0.7) {
            self.view.layoutIfNeeded()
        }
    }

    func updateTableView() {
        self.refreshControl.endRefreshing()
        self.collectionView.reloadData()
        addCoreSpoth()
    }

    func loadData() {
        self.sorryMessage.hidden = true
        
        let userControl = UserManager()
        
        userControl.getMutualFriends(UserManager.currentUser()!, callback: { (friends, error) -> () in
            if(error == nil) {
                self.friends = friends
                self.activityIndicator.stopAnimating()
                self.updateTableView()
                if(self.friends.count == 0) {
                    self.sorryMessage.hidden = false
                }
            }
        })
    }

    func loadByPushNotification() {
        let tabBarController = self.navigationController as! MainViewController
        if let pushType = tabBarController.pushType {
            if(pushType == "searchios9") {
                self.userSelected = tabBarController.pushPhotoId
                self.performSegueWithIdentifier("selectSound", sender: nil)
            }

            tabBarController.pushPhotoId = nil
            tabBarController.pushType = nil
        }
    }

    @IBAction func backFromSendPush(segue:UIStoryboardSegue) {
        if sendMessage {
            showSuccessMessage()
        }
    }
    
    @IBAction func showMessages(sender: AnyObject) {
        self.performSegueWithIdentifier("messages", sender: nil)
    }

    func hideSuccessMessage() {
        successMessageTopConstraint.constant = -55
        
        UIView.animateWithDuration(0.7) {
            self.view.layoutIfNeeded()
        }
    }

    func addCoreSpoth() {
        if #available(iOS 9.0, *) {
            CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["colorados"]) { (error) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    var searchableItems: [CSSearchableItem] = []
                    
                    for userControl in self.friends {
//                        if let userControl = show as? UserManager {

                            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)

                            attributeSet.title = userControl.name
                            
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.timeStyle = .ShortStyle
                            
                            attributeSet.contentDescription = "Torcedor gremista \nEnviar mensagem"
                            
                            if let url = NSURL(string: (userControl.photo!.url)!) {
                                attributeSet.thumbnailURL = url
                            }
                            
                            let keywords = userControl.name.componentsSeparatedByString(" ")
                            attributeSet.keywords = keywords
                            
                            let item = CSSearchableItem(uniqueIdentifier: userControl.objectId, domainIdentifier: "colorados", attributeSet: attributeSet)
                            searchableItems.append(item)
                        }
//                    }

                    CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { (error) -> Void in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                        else {
                            UserDefaultsManager.loadSpot = true
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! FriendsCollectionViewCell
        
        cell.userPhoto.layer.cornerRadius = cell.userPhoto.frame.size.width / 2
        cell.userPhoto.clipsToBounds = true
        
        let borderBottom = CALayer()
        let borderRight = CALayer()
        let borderTop = CALayer()
        
        let stroke = CGFloat(1.0)
       
        borderBottom.borderColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 204/255.0, alpha: 1.0).CGColor
        borderBottom.frame = CGRect(x: 0, y: cell.frame.size.height - stroke, width: cell.frame.size.width, height: cell.frame.size.height)
        borderBottom.borderWidth = stroke
        
        borderTop.borderColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 204/255.0, alpha: 1.0).CGColor
        borderTop.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 1)
        borderTop.borderWidth = stroke

        borderRight.borderColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 204/255.0, alpha: 1.0).CGColor
        borderRight.frame = CGRect(x: cell.frame.size.width - stroke, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        borderRight.borderWidth = stroke

        cell.layer.addSublayer(borderBottom)
        
        collectionView.layer.addSublayer(borderTop)
        
        if ((indexPath.row + 1) % 3 != 0) {
            cell.layer.addSublayer(borderRight)
        }

        cell.layer.masksToBounds = true
        
        
        let userControl = self.friends[indexPath.row]
        let resultName = userControl.name.componentsSeparatedByString(" ")
        cell.userName.text = resultName[0] as String
        
        let url = NSURL(string: userControl.photo!.url!)
        cell.userPhoto.setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"),usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

        cell.userPhoto.layer.cornerRadius = cell.userPhoto.frame.size.width / 2
        cell.userPhoto.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let columnWidth = self.collectionView.frame.size.width / 3
        return CGSizeMake(columnWidth, 125);
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 244/255.0, alpha: 1.0)
        cell?.selectedBackgroundView = view
        
        let userControl = self.friends[indexPath.row]
        self.userSelected = userControl.objectId

        self.performSegueWithIdentifier("selectSound", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "selectSound") {
            let rVC : SoundsViewController = segue.destinationViewController as! SoundsViewController
            
            rVC.userIdSend = self.userSelected!
        } else if(segue.identifier == "messages") {
            let rVC : MessagesViewController = segue.destinationViewController as! MessagesViewController
            rVC.friends = self.friends

            rVC.isRoot = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
