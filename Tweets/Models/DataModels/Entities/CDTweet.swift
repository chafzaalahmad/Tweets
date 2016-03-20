//
//  CDTweet.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import Foundation
import CoreData

/// Core Data Tweet class
class CDTweet: NSManagedObject {

    /**
     Initilize CDTweet object using Tweet model
     
     - parameter objTweet: source objTweet object
     
     - returns: void
     */
    func initWithTweetModel(objTweet: Tweet) -> Void{
        if let id = objTweet.id{
            self.id = id
        }
        self.text = objTweet.text
        self.name = objTweet.name
        self.profileImage = objTweet.profileImage
    }

}
