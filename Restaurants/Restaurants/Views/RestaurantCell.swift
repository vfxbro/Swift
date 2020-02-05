//
//  RestaurantCell.swift
//  Restaurants
//
//  Created by Igor Boldyrev on 30/07/2019.
//  Copyright © 2019 Igor Boldyrev All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {

    @IBOutlet weak var raitingImageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var restaurantComments: UILabel!
    
    var restaurant: Restaurant? {
        didSet {
            if let restaurant = restaurant {
                restaurantLabel.text = restaurant.name
                restaurantComments.text = restaurant.comments
                raitingImageView.image = UIImage(named: "Stars\(restaurant.rating)")
            } else {
                restaurantLabel.text = ""
                restaurantComments.text = ""
                raitingImageView.image = nil
            }
        }
    }

}
