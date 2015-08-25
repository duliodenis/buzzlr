//
//  ViewController.swift
//  buzzlr
//
//  Created by Dulio Denis on 8/25/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController, FlurryAdNativeDelegate, UITableViewDataSource, UITableViewDelegate {

    var images: [UIImage]?
    var tableView: UITableView?
    let CellIdentifier: String = "CELL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.images = [UIImage]()
        
        let OAUTH = "OAuthData"
        let BUZZLR = "buzzlr"
        // Load from the Keychain
        let (oAuthData, _) = Locksmith.loadDataForUserAccount(OAUTH, inService: BUZZLR)
        // Do we have one?
        if let accessToken: AnyObject = oAuthData?.objectForKey("accessToken") {
            // We got the data back, so we’ve got an access token
            getTumblrData()
        } else {
            // Locksmith couldn’t find anything in the keychain
           autoLoginTumblr()
        }
        
        var frame = CGRectMake(10, 0, self.view.bounds.width - 10, self.view.bounds.height)
        tableView = UITableView(frame: frame, style: .Plain)
        
        if let newTable = tableView {
            newTable.registerClass(ImageTableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
            newTable.dataSource = self
            newTable.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            view.addSubview(newTable)
        }

    }
    
    func autoLoginTumblr() {
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
                
                let swiftyJson = JSON(data: data)
                let numberOfPhotos = swiftyJson["response"].count
                for photoIndex in 0..<numberOfPhotos {
                    let foundImage = swiftyJson["response"][photoIndex]["photos"][0]["original_size"]["url"].stringValue
                    let image = self.imageFromPath(foundImage)
                    if image != nil {
                       self.images?.append(image!)
                    }
                }
                print(self.images?.count)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.tableView?.reloadData()
                })

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
    
    // MARK: - TableView Delegte Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberInArray = images!.count
        return numberInArray
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ImageTableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! ImageTableViewCell

        let row = indexPath.row
                
        cell.imageView?.image = images![indexPath.row]
        cell.imageView?.image = decorateImage("If you were a vegetable you'd be a cute-cumber.",
            originalImage: images![indexPath.row], atPoint: CGPointMake(40, 120))
        cell.imageView?.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView!.frame), 400)
        
        cell.imageView?.contentMode = .ScaleAspectFill
        

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 400.0
    }

    
    // MARK: - Photo Helper Methods
    
    func decorateImage(pickupLine:NSString, originalImage: UIImage, atPoint: CGPoint) -> UIImage {
        var textColor: UIColor = UIColor.whiteColor()
        var textFont: UIFont = UIFont(name: "Baskerville", size: 40)!
        
        UIGraphicsBeginImageContext(originalImage.size)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor
        ]
        
        originalImage.drawInRect(CGRectMake(0, 0, originalImage.size.width, originalImage.size.height))
        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, originalImage.size.width, originalImage.size.height)
        pickupLine.drawInRect(rect, withAttributes: textFontAttributes)
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    
}

