//
//  Utilities.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//


import UIKit
/// Use for helper methods
class Utilities {

    /**
     Show Alert View base on error object
     
     - parameter error:      error object contain informations of error
     - parameter controller: where show error alert view
     */
    class func showError(error : NSError? , controller:UIViewController?) {

        if let err = error{
            let alert = UIAlertController(title: err.domain, message: err.localizedDescription, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
            controller!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
