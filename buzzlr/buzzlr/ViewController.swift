//
//  ViewController.swift
//  buzzlr
//
//  Created by Dulio Denis on 8/25/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController, FlurryAdNativeDelegate {

    var images: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTumblr(sender: AnyObject) {
        let oauthswift = OAuth1Swift(
            consumerKey:    "CC3BXFyI4YwGviO2AZk3fM1jgHdaa6WtKO7x9YxbAjNvqvqfhl",
            consumerSecret: "VuesMgrRKvsj1L3qCFdM0ECJeV8YJGafMPwpzTOSeFhRpB07nI",
            requestTokenUrl: "https://www.tumblr.com/oauth/request_token",
            authorizeUrl:    "https://www.tumblr.com/oauth/authorize",
            accessTokenUrl:  "https://www.tumblr.com/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/tumblr")!, success: {
            credential, response in
            
            // Save the token data
            let OAUTH = "OAuthData"
            let BUZZLR = "buzzlr"
            
            let error = Locksmith.saveData(["accessToken": credential.oauth_token as String],
                forUserAccount: OAUTH, inService: BUZZLR)
            
            self.showAlertView("Tumblr", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            self.getTumblrData()
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
        })
/*
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
*/
    }

    func showAlertView(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func getTumblrData() {
        let TAG = "BusinessMen"
        let API_KEY = "CC3BXFyI4YwGviO2AZk3fM1jgHdaa6WtKO7x9YxbAjNvqvqfhl"
        let urlPath = NSURL(string: "https://api.tumblr.com/v2/tagged?tag=\(TAG)&api_key=\(API_KEY)")
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(urlPath!) {
            data, response, error -> Void in
            
            if ((error) != nil) {
                print(error.localizedDescription)
            }
            
            var jsonError : NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as! NSDictionary
            
            if ((jsonError) != nil) {
                print(jsonError!.localizedDescription)
            } else {
                // print(jsonResult)
                self.images = [UIImage]()
               // let imageUrl = jsonResult[“data”][“media”]["images"]["low_resolution"]["url"].stringValue
                let swiftyJson = JSON(data: data)
                let numberOfPhotos = swiftyJson["response"].count
                for photoIndex in 0..<numberOfPhotos {
                    let foundImage = swiftyJson["response"][photoIndex]["photos"][0]["original_size"]["url"].stringValue
                    let image = self.imageFromPath(foundImage)
                    if image != nil {
                       self.images?.append(image!)
                    }
                }
                // let imageUrl = swiftyJson["response"][0]["photos"][0]["original_size"]["url"].stringValue
                print(self.images?.count)
//                if let response: AnyObject = jsonResult["response"] {
//                    if let firstResponse: AnyObject = response[0] {
//                        if let photos: AnyObject = firstResponse["photos"] {
//                            if let photoURL: AnyObject = photos[
//                            print(photos)
//                        }
//                    }
//                }
            }
        }
        task.resume()
    }


    // MARK: - Image Helper Functions
    
    func imageFromPath(path: String) -> UIImage? {
        let tumblrURL = NSURL(string: path)
        if let imageData = NSData(contentsOfURL: tumblrURL!) {
            return UIImage(data: imageData)
        }
        return nil
        
    }
    
}

