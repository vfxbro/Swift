//
//  AddRestaurantViewController.swift
//  Restaurants
//
//  Created by Igor Boldyrev on 30/07/2019.
//  Copyright © 2019 Igor Boldyrev All rights reserved.
//

import UIKit
import MapKit

protocol AddRestaurantViewControllerDelegate: class {
    func addRestaurantViewControllerDidCancel(_ controller: AddRestaurantViewController)
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishAdding restaurant: Restaurant)
    func addRestaurantViewController(_ controller: AddRestaurantViewController, didFinishEditing restaurant: Restaurant)
}

class AddRestaurantViewController: UIViewController {
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: AddRestaurantViewControllerDelegate?
    var restaurantToEdit: Restaurant?
    let locationManager = CLLocationManager()
    let annotation = MKPointAnnotation()
    
    private var starSet = [UIImageView]()
    private var selectedStar = 0
    private var newPhoto = false
    private var latitude: Double = 0
    private var longtitude: Double = 0
    private var newLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        setupView()
    }
    
    func setupView() {
        commentsTextView.layer.cornerRadius = 4
        restaurantImageView.layer.cornerRadius = 12
        mapView.layer.cornerRadius = 12
        
        if let restaurant = restaurantToEdit {
            title = "Редактирование"
            textField.text = restaurant.name
            commentsTextView.text = restaurant.comments
            selectedStar = restaurant.rating
            
            if !restaurant.photoFileName.isEmpty {
                restaurantImageView.image = RestaurantsDataSource.shared.loadRestaurantPhoto(fileName: restaurant.photoFileName)
            }
            
            // Установить булавку
            if let latitude = restaurant.latitude, let longtitude = restaurant.longtitude {
                setAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude),
                              name: restaurant.name)
            }
            
            doneBarButton.isEnabled = true
        }
        
        starSet = makeStarSet()
        starSet.forEach { (imageView) in
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap))
            imageView.addGestureRecognizer(tapGR)
        }
        configureStars(tag: selectedStar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    func setAnnotation(coordinate: CLLocationCoordinate2D, name: String) {
        mapView.removeAnnotation(annotation)
        
        annotation.title = name
        //annotation.subtitle = "Мое местоположение"
        annotation.coordinate = coordinate
        
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.addRestaurantViewControllerDidCancel(self)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        if let restaurant = restaurantToEdit {
            restaurant.name = textField.text!
            restaurant.rating = selectedStar
            restaurant.comments = commentsTextView.text
            if newLocation {
                restaurant.latitude = latitude
                restaurant.longtitude = longtitude
            }
            if newPhoto {
                if restaurant.photoFileName.isEmpty {
                    restaurant.photoFileName = UUID().description + ".jpg"
                }
                RestaurantsDataSource.shared.saveRestaurantPhoto(image: restaurantImageView.image!,
                                                                 fileName: restaurant.photoFileName)
            }
            
            delegate?.addRestaurantViewController(self, didFinishEditing: restaurant)
        } else {
            let restaurant = Restaurant()
            restaurant.name = textField.text!
            restaurant.rating = selectedStar
            restaurant.comments = commentsTextView.text
            if newLocation {
                restaurant.latitude = latitude
                restaurant.longtitude = longtitude
            }
            if newPhoto {
                restaurant.photoFileName = UUID().description + ".jpg"
                RestaurantsDataSource.shared.saveRestaurantPhoto(image: restaurantImageView.image!,
                                                                 fileName: restaurant.photoFileName)
            }
            delegate?.addRestaurantViewController(self, didFinishAdding: restaurant)
        }
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func setLocation(_ sender: UIButton) {
        // Установить булавку
        if let location = locationManager.location {
            newLocation = true
            
            let coordinate = location.coordinate
            latitude = coordinate.latitude
            longtitude = coordinate.longitude
            
            setAnnotation(coordinate: coordinate, name: textField.text!)
        }
    }
    
    // MARKS: - Методы для работы со звездами
    
    // Формирует массив со звездами (UIImageView)
    func makeStarSet() -> [UIImageView] {
        var stars = [UIImageView]()
        for i in 1...5 {
            let imageView = view.viewWithTag(i) as! UIImageView
            stars.append(imageView)
        }
        return stars
    }
    
    // Обработчик для распознователя жестов для всех звезд
    @objc func didTap(tapGR: UITapGestureRecognizer) {
        if let tag = tapGR.view?.tag {
            configureStars(tag: tag)
            selectedStar = tag
        }
    }
    
    // Конфигурирование всех звезд
    func configureStars(tag: Int) {
        starSet.forEach { (imageView) in
            if imageView.tag <= tag {
                // Золотая звезда
                imageView.image = UIImage(named: "GoldStar")
            } else {
                // Серая звезда
                imageView.image = UIImage(named: "GrayStar")
            }
        }
    }
    
}

extension AddRestaurantViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    }
}

extension AddRestaurantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] {
            restaurantImageView.image = image as? UIImage
            newPhoto = true
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
