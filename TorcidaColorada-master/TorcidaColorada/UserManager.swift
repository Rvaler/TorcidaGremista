//
//  UserManager.swift
//  TorcidaColorada
//
//  Created by Matheus Frozzi Alberton on 24/08/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit

class UserManager: PFUser {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    @NSManaged var name: String!
    @NSManaged var facebookId: String?
    @NSManaged var photo: PFFile?

    func getUsers(callback: (users: NSArray?, error: NSError?) -> ()) {
        let query = UserManager.query()!
        
        var auxUsers: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxUsers = objects!
                callback(users: auxUsers, error: nil)
            } else {
                callback(users: nil, error: error!)
            }
        }
    }

    func returnUserData(user: UserManager, callback: (error: NSError?) -> ()) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if (error != nil) {
                callback(error: error)
            }
            else {
                let currentUser : UserManager = user
                
                let userID: String! = result.valueForKey("id") as! String
                //                currentUser.objectId = user.objectId
                
                currentUser.facebookId = userID
                
                if let userName = result.valueForKey("name") as? NSString {
                    currentUser.name = userName as String
                }
                
                if let userEmail = result.valueForKey("email") as? NSString {
                    currentUser.email = userEmail as String
                }
                
                if(userID != nil) {
                    currentUser.facebookId = userID
                    
                    let swiftString: String! = "https://graph.facebook.com/\(userID!)/picture?type=large"
                    
                    let url = NSURL(string: swiftString)
                    let data = NSData(contentsOfURL: url!)
                    
                    print(swiftString)

                    let image: UIImage = UIImage(data: data!)!
                    let jpegImage = UIImageJPEGRepresentation(image, 1.0)
                    let file = PFFile(name:currentUser.objectId! + ".jpg" , data: jpegImage!)

                    currentUser.photo = file
                }
                
                currentUser.editUser(currentUser, callback: { (success, error) -> () in
                    if (success) {
                        callback(error: nil)
                    } else {
                        callback(error: error)
                    }
                })
            }
        })
    }
    
    func editUser(user: UserManager, callback: (success: Bool, error: NSError?) -> ()) {
        user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if(success == true) {
                callback(success: true, error: nil)
            } else {
                callback(success: false, error: error)
            }
        })
    }
    
    func getMutualFriends(user: UserManager, callback: (friends: [UserManager], error: NSError?) -> ()) {
        let fbRequestFriends : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id"])

        fbRequestFriends.startWithCompletionHandler{
            (connection:FBSDKGraphRequestConnection!,result:AnyObject?, error:NSError!) -> Void in
            
            var auxUsers: NSArray!
            
            if error == nil && result != nil {
                auxUsers = result!["data"]! as! NSArray
                var fbID = [String]()
                
                for user in auxUsers {
                    let fbIDe = user["id"]! as! String
                    fbID.append(fbIDe)
                }
                
                let friendQuery = UserManager.query()!

                var resultUsers : [UserManager] = []

                friendQuery.whereKey("facebookId", containedIn: fbID as [AnyObject])
                friendQuery.findObjectsInBackgroundWithBlock {
                    (objects, error) -> Void in
                    if error == nil {
                        resultUsers = objects! as! [UserManager]
                        callback(friends: resultUsers, error: nil)
                    } else {
                        callback(friends: [], error: error)
                    }
                }
            } else {
                callback(friends: [], error: error)
            }
        }
    }

}