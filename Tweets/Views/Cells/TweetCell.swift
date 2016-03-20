//
//  TweetCell.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import UIKit
import SDWebImage

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    func configureView(name : String?, tweetText : String?, profileImageUrl : String?){
        
        nameLabel?.text = name
        tweetTextLabel?.text = tweetText
        
        if let profileImage = profileImageUrl{
            profileImageView?.sd_setImageWithURL(NSURL(string: profileImage), placeholderImage: UIImage(named: "blank-profile"))
        }
        
        
    }
    
}
