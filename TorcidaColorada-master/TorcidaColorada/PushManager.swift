//
//  PushManager.swift
//  vamointer
//
//  Created by Matheus Frozzi Alberton on 13/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class PushManager: NSObject {
    static func associateDeviceWithCurrentUser() {        
        let installation = PFInstallation.currentInstallation()
        
        if((installation["user"] == nil) && PFUser.currentUser() != nil) {
            installation["user"] = PFUser.currentUser()
            installation.saveInBackground()
        }
    }

    static func sendPush(message: String, sound: String, userId: String) {
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("user", equalTo: PFUser.objectWithoutDataWithObjectId(userId))

        let data = [
            "alert" : message,
            "badge" : "Increment",
            "sound" : sound + ".caf"
        ]

        let push = PFPush()
        push.setQuery(pushQuery)
        push.setData(data)
        push.sendPushInBackground()
    }
}