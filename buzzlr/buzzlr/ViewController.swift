//
//  ViewController.swift
//  buzzlr
//
//  Created by Dulio Denis on 8/25/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 20, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout:layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "ident")
        collectionView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView!)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ident", forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @IBAction func loginTumblr(sender: AnyObject) {
        let oauthswift = OAuth1Swift(
            consumerKey:    "CC3BXFyI4YwGviO2AZk3fM1jgHdaa6WtKO7x9YxbAjNvqvqfhl",
            consumerSecret: "VuesMgrRKvsj1L3qCFdM0ECJeV8YJGafMPwpzTOSeFhRpB07nI",
            requestTokenUrl: "http://www.tumblr.com/oauth/request_token",
            authorizeUrl:    "http://www.tumblr.com/oauth/authorize",
            accessTokenUrl:  "http://www.tumblr.com/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/tumblr")!, success: {
            credential, response in
            
            // Save the token data
            let OAUTH = "OAuthData"
            let BUZZLR = "buzzlr"
            
            let error = Locksmith.saveData(["accessToken": credential.oauth_token as String],
                forUserAccount: OAUTH, inService: BUZZLR)
            
            self.showAlertView("Tumblr", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
        })
        
        let OAUTH = "OAuthData"
        let BUZZLR = "buzzlr"
        // Load from the Keychain
        let (oAuthData, _) = Locksmith.loadDataForUserAccount(OAUTH, inService: BUZZLR)
        // Do we have one?
        if let accessToken: AnyObject = oAuthData?.objectForKey("accessToken") {
            // We got the data back, so we’ve got an access token
            self.showAlertView("Token", message: "We have a token: \(accessToken)")
        } else {
            // Locksmith couldn’t find anything in the keychain
            self.showAlertView("Token", message: "No token found.")
        }
        
    }
    
    func showAlertView(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

