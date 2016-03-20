//
//  NSManagedObject+CRUD.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Helper method for create , find, delete NSManagedObject
extension NSManagedObject {
    
    /**
     Use for get Class name
     
     - returns: class name
     */
    class func entityName() -> String {
        var name = self.classForCoder().description()
        name = name.componentsSeparatedByString(".").last!
        return name
    }
    
    /**
     Create NSManagedObject base on class name
     
     - returns: NSManagedObject base on class name
     */
    class func create() -> NSManagedObject?{
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: CoreDataStack.sharedStack.managedObjectContext)
    }
    
    /**
     Find NSManagedObject base on object id
     
     - parameter id: id of object
     
     - returns: NSManagedObject if found else return nil
     */
    class func findByID(id :Int32) -> NSManagedObject?{
        
        let manageObjectContext = CoreDataStack.sharedStack.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: self.entityName())
        let predicate = NSPredicate(format: "id == %i", id)        
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do
        {
            let fetchResults = try manageObjectContext.executeFetchRequest(fetchRequest)
            if(!fetchResults.isEmpty){
                return fetchResults.last as? NSManagedObject
            }
            
        } catch let error as NSError {
            print("Error : \(error) \(error.userInfo)")
        }
        
        return nil
    }
    
    /**
     Delete current object from managedObjectContext
     
     - returns: true if deleted else false
     */
    func deleteMe() -> Bool{
        let managedObjectContext = CoreDataStack.sharedStack.managedObjectContext
        managedObjectContext.deleteObject(self)
        do {
            try managedObjectContext.save()
            return true
        } catch {
            let saveError = error as NSError
            print(saveError)
            return false
        }
    }
}
