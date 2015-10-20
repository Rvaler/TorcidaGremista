//
//  AppDelegate.swift
//  vamointer
//
//  Created by Matheus Frozzi Alberton on 09/07/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4
import CoreSpotlight
import MobileCoreServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId("LUM7oGqcKeda5xKUC9TTXqfP6u2cYffZVlONrUdD",
            clientKey: "kJzgRu6FvfCvmgzqw7n1iIu4IvIkiQ0R3NBGe8g8")
        
        UserManager.registerSubclass()
        SoundManager.registerSubclass()
        Messages.registerSubclass()

        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        UINavigationBar.appearance().barTintColor = UIColor.gremioBlueColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        
        print(installation.objectId)

        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("Token adicionado com sucesso")
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
//            let tabBarController = self.window!.rootViewController as! FriendsViewController
            
            if let window = self.window {
//                window.rootViewController?.restoreUserActivityState(userActivity)
                if userActivity.activityType == CSSearchableItemActionType {
                    if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                        if let view = window.rootViewController as? MainViewController {
                            view.popToRootViewControllerAnimated(false)
                            view.pushPhotoId = identifier
                            view.pushType = "searchios9"

                            NSNotificationCenter.defaultCenter().postNotificationName("openSpot", object: nil)
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }

}

