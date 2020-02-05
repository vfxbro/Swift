//
//  RestaurantsViewController.swift
//  Restaurants
//
//  Created by Igor Boldyrev on 30/07/2019.
//  Copyright © 2019 Igor Boldyrev All rights reserved.
//

import UIKit

class RestaurantViewController: UITableViewController {
    
    let restaurantsDataSource = RestaurantsDataSource.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        //print(restaurantsDataSource.documentDirectory().path)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        
        let restaurant = restaurantsDataSource.getRestaurant(index: indexPath.row)
        cell.restaurant = restaurant
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            restaurantsDataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        restaurantsDataSource.saveRestaurants()
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        restaurantsDataSource.moveRowAt(from: fromIndexPath.row, to: to.row)
        restaurantsDataSource.saveRestaurants()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddRestaurant" {
            let controller = segue.destination as! AddRestaurantViewController
            controller.delegate = self
        } else if segue.identifier == "EditRestaurant" {
            let controller = segue.destination as! AddRestaurantViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.restaurantToEdit = restaurantsDataSource.getRestaurant(index: indexPath.row)
            }
        }
    }
    
}

extension RestaurantViewController: AddRestaurantViewControllerDelegate {
    
    func addRestaurantViewControllerDidCancel(_ controller: AddRestaurantViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishAdding restaurant: Restaurant) {
        let newRowIndex = restaurantsDataSource.count
        restaurantsDataSource.append(restaurant)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        navigationController?.popViewController(animated: true)
        restaurantsDataSource.saveRestaurants()
    }
    
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishEditing restaurant: Restaurant) {
        if let index = restaurantsDataSource.firstIndex(of: restaurant) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        navigationController?.popViewController(animated: true)
        restaurantsDataSource.saveRestaurants()
    }
    
}

