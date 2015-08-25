//
//  AppDelegate.swift
//  buzzlr
//
//  Created by Dulio Denis on 8/25/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Flurry.startSession("CHSH9JPVKNTVBQ4Z3WBG")
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if (url.host == "oauth-callback") {
            if (url.path!.hasPrefix("/tumblr")){
                OAuth1Swift.handleOpenURL(url)
            }
        }
        return true
    }

}

