//
//  CDTweet+CoreDataProperties.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDTweet {

    @NSManaged var name: String?
    @NSManaged var profileImage: String?
    @NSManaged var text: String?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var id: NSNumber?

}
