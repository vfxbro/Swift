//
//  Restaurant.swift
//  Restaurants
//
//  Created by Igor Boldyrev on 30/07/2019.
//  Copyright © 2019 Igor Boldyrev All rights reserved.
//

import Foundation

class Restaurant: NSObject, NSCoding {
    var name = ""
    var rating = 0
    var comments = ""
    var photoFileName = ""
    var latitude: Double?
    var longtitude: Double?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        rating = aDecoder.decodeInteger(forKey: "Raiting")
        comments = aDecoder.decodeObject(forKey: "Comments") as! String
        photoFileName = aDecoder.decodeObject(forKey: "PhotoFileName") as! String
        latitude = aDecoder.decodeObject(forKey: "Latitude") as? Double
        longtitude = aDecoder.decodeObject(forKey: "Longtitude") as? Double
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(rating, forKey: "Raiting")
        aCoder.encode(comments, forKey: "Comments")
        aCoder.encode(photoFileName, forKey: "PhotoFileName")
        aCoder.encode(latitude, forKey: "Latitude")
        aCoder.encode(longtitude, forKey: "Longtitude")
    }
    
}
