//
//  UserDefaultsManager.swift
//  TorcidaColorada
//
//  Created by Matheus Frozzi Alberton on 25/09/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit

private let CoreSpot = "CoreSpotlight"

class UserDefaultsManager: NSObject {
    class var loadSpot: Bool? {
        get {
        return NSUserDefaults.standardUserDefaults().valueForKey(CoreSpot) as? Bool
        }
        set(newProperty) {
            NSUserDefaults.standardUserDefaults().setValue(newProperty, forKey: CoreSpot)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}