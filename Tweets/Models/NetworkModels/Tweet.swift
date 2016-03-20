//
//  Tweet.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import UIKit
import Mantle

/// Contain some Tweet informations
class Tweet: MTLModel ,MTLJSONSerializing {
    
    var id: NSNumber?
    var name:String?
    var profileImage:String?
    var text:String?
    
    /**
     Define keys Mapping rules
     
     - returns: dictionary of keys mapping rules
     */
    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "id":"id",
            "name":"user.name",
            "profileImage":"user.profile_image_url",
            "text":"text"
        ]
        
    }
    
    /**
     Map tweets array dictionary to Tweet array object
     
     - parameter tweetsDic: tweets array dictionary which map
     
     - returns: mapped array of Tweet objects
     */
    static func tweetFromDictionary(tweetsDic : [[String : AnyObject]]?) -> [Tweet]?{
        
        var tweets : [Tweet] = []
        do{
            if let tweetsDicArr = tweetsDic{
                for josnTweet in tweetsDicArr{
                    
                    /// Create Tweet object using Mantle library method
                    if let tweet = try MTLJSONAdapter.modelOfClass(Tweet.self, fromJSONDictionary: josnTweet) as? Tweet{
                        tweets.append(tweet)
                    }
                }
            }
            
        }
        catch{

        }
        return tweets
        
    }
    
}
