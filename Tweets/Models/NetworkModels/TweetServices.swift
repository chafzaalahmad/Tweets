//
//  TweetServices.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import Accounts
import Social
import Mantle
import Alamofire

/// Twitter response handler block prototype
typealias TweetCompletionBlock = (tweets: [Tweet]?, error: NSError?) -> Void

/// TweetServices handle Twitter account permission, search tweets
class TweetServices: NSObject {
    
    var twitterAccount: ACAccount?
    var request : Request?
    var completionBlock : TweetCompletionBlock?
    var searchParm : [NSObject : AnyObject]?
    
    /**
     Get tweets from server 
     https://dev.twitter.com/rest/reference/get/search/tweets
     
     - parameter searchParm: search parameters dictionary
     - parameter completion: Twitter response handler
     */
    func getTweets(searchParm: [NSObject : AnyObject]?, completion: TweetCompletionBlock?) {
        

        /// Cancel first request first
        self.cancelRequest()
        
        self.completionBlock = completion
        self.searchParm = searchParm
        
        /**
        *  get Twitter account from device and than call search tweet method
        */
        if(self.twitterAccount == nil){
            self.configTwitterAccount { (twitterAccount, error) -> Void in
                if(error == nil){
                    self.twitterAccount = twitterAccount
                    self.searchTweets()
                }
                else
                {
                    if let completionBlock = self.completionBlock{
                        completionBlock(tweets: nil, error: error)
                    }
                    
                }
            }
        }
        else
        {
            self.searchTweets()
        }
        
    }
    
    /**
     Search Tweets from Twitter server and parse response and call completion block "TweetCompletionBlock"
     https://dev.twitter.com/rest/reference/get/search/tweets
     */
    private func searchTweets(){
        if let twitterAcc = twitterAccount{
            
            /// Create Twitter search tweets request
            let requestURL = NSURL(string:Twitter.SearchTweetsURL)
            let getRequest = SLRequest(forServiceType:SLServiceTypeTwitter,requestMethod: SLRequestMethod.GET,URL: requestURL,parameters: self.searchParm)
            
            getRequest.account = twitterAcc
            
            if let getNSURLRequest = getRequest.preparedURLRequest(){
    
                self.request = Alamofire.request(getNSURLRequest).response(completionHandler: { (request: NSURLRequest?, URLResponse:NSHTTPURLResponse?, data:NSData?, eror: NSError?) -> Void in
                    
                    if let err = eror {
                        if let completionBlock = self.completionBlock{
                            completionBlock(tweets: nil, error: err)
                        }
                        
                        return
                    }
                    else
                    {
                        do{
                            /// Parse response to Tweet array and return to completionBlock "TweetCompletionBlock"
                            if let response = data{
                                let data = try NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves)
                                
                                if let responsDic = data as? [String : AnyObject]{
                                    
                                    if let statuses = responsDic["statuses"] as? [[String : AnyObject]]{
                                        if let completionBlock = self.completionBlock{
                                            completionBlock(tweets: Tweet.tweetFromDictionary(statuses), error: nil)
                                        }
                                        return
                                    }
                                }
                            }
                            
                        }
                        catch{
                            if let completionBlock = self.completionBlock{
                                completionBlock(tweets: nil, error: nil)
                            }
                        }
                        if let completionBlock = self.completionBlock{
                            completionBlock(tweets: nil, error: nil)
                        }
                        
                    }
                    
                })
            }
            
            
            
        }
        else
        {
            if let completionBlock = self.completionBlock{
                completionBlock(tweets: nil, error: nil)
            }
        }
    }

    /**
     Get Twitter account from device by using Account framework
     
     - parameter accountCompletion: return ACAccount object or error in block
     */
    private func configTwitterAccount(accountCompletion: (twitterAccount: ACAccount? , error: NSError?) ->Void){
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success: Bool, error: NSError!) -> Void in
                
                if success {
                    let arrayOfAccounts =
                    account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        let twitterAccount = arrayOfAccounts.last as? ACAccount
                        accountCompletion(twitterAccount: twitterAccount, error: nil)
                    }
                    else
                    {
                        /// create custom error object if Twitter accounts not found in device
                        let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorised", value: "There are no Twitter accounts. You can add or create a Twitter account in device Settings.", comment: ""),
                            NSLocalizedFailureReasonErrorKey : NSLocalizedString("Unauthorised", value: "There are no Twitter accounts. You can add or create a Twitter account in device Settings.", comment: "")
                        ]
                        let error = NSError(domain: "No Twitter Accounts", code: 401, userInfo: userInfo)
                        
                        accountCompletion(twitterAccount: nil, error: error)
                    }
                    
                }
                else
                {
                    if(error == nil)
                    {
                        /// create custom error object if Twitter accounts permissions are disabled
                        let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorised", value: "Twitter accounts permissions are disabled.", comment: ""),
                            NSLocalizedFailureReasonErrorKey : NSLocalizedString("Unauthorised", value: "Twitter accounts permissions are disabled.", comment: "")
                        ]
                        
                        let err = NSError(domain: "Twitter Accounts Permissions", code: 401, userInfo: userInfo)
                        accountCompletion(twitterAccount: nil, error: err)
                    }
                    else
                    {
                        accountCompletion(twitterAccount: nil, error: error)
                    }

                }
                
        })
    }
    
    /**
     Cancel request if request is created and clear completionBlock and search parms
     */
    func cancelRequest(){
        if(request != nil){
            request?.cancel()
            request = nil
            
            self.completionBlock = nil
            self.searchParm = nil
            
        }
    }
}
