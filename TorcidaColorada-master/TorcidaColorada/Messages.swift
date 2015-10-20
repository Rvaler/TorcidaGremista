//
//  Messages.swift
//  TorcidaColorada
//
//  Created by Matheus Frozzi Alberton on 07/10/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit

class Messages: PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Message"
    }

    @NSManaged var user: UserManager?
    @NSManaged var userTo: UserManager?
    @NSManaged var sound: SoundManager?

    func getMessages(callback: (allMessages: [Messages], error: NSError?) -> ()) {
        let query = PFQuery(className: Messages.parseClassName())

        query.whereKey("userTo", equalTo: UserManager.currentUser()!)

        query.includeKey("user")
        query.includeKey("sound")
        query.orderByAscending("createdAt")
        
        query.limit = 40

        var auxSounds: [Messages] = []

        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxSounds = objects as! [Messages]
                callback(allMessages: auxSounds, error: nil)
            } else {
                callback(allMessages: [], error: error!)
            }
        }
    }
    
    func sendMessage(callback: (success: Bool, error: NSError?) -> ()) {
        
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            callback(success: success, error: error)
        }
    }
}
