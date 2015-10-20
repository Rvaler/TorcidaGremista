//
//  SoundManager.swift
//  TorcidaColorada
//
//  Created by Matheus Frozzi Alberton on 24/08/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit

class SoundManager: PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    static func parseClassName() -> String {
        return "Sound"
    }

    @NSManaged var fileName: String?
    @NSManaged var name: String?
    @NSManaged var mp3: PFFile?

    func getSounds(callback: (allSounds: [SoundManager], error: NSError?) -> ()) {
        let query = PFQuery(className: SoundManager.parseClassName())

        query.orderByAscending("name")
        
        var auxSounds: [SoundManager] = []
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxSounds = objects! as! [SoundManager]
                callback(allSounds: auxSounds, error: nil)
            } else {
                callback(allSounds: [], error: error!)
            }
        }
    }
}