//
//  ViewControllerAdd.swift
//  IamHereApp
//
//  Created by Yavuz Ulgar on 12.01.2023.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ViewControllerAdd: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapLabel: MKMapView!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var choosenLantitude = Double()
    var choosenLongtitude = Double()
    
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        let hideGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(hideGesture)

        imageLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageLabel.addGestureRecognizer(gestureRecognizer)

        mapLabel.delegate = self
        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let mapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation))
        mapRecognizer.minimumPressDuration = 2
        mapLabel.addGestureRecognizer(mapRecognizer)
    }

    @objc func chooseLocation(mapRecognizer:UILongPressGestureRecognizer) {
        if mapRecognizer.state == .began {
            
            let touchPoint = mapRecognizer.location(in: self.mapLabel)
            let touchedCoordinates = self.mapLabel.convert(touchPoint, toCoordinateFrom: self.mapLabel)

            choosenLantitude = touchedCoordinates.latitude
            choosenLongtitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = textField.text
            if textField.text == "" {
                kontrolMessage(titleInput: "Alert", messageInput: "Please enter title")
            } else {
                mapLabel.addAnnotation(annotation)
                saveButton.isEnabled = true
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinates = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapLabel.setRegion(region, animated: true)
    }
    
    func kontrolMessage(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageLabel.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        if textField.text == "" {
            kontrolMessage(titleInput: "Alert", messageInput: "Please enter title")
        } else {
            newPlace.setValue(textField.text, forKey: "title")
        }
        newPlace.setValue(UUID(), forKey: "id")
        
        newPlace.setValue(choosenLantitude, forKey: "latitude")
        newPlace.setValue(choosenLongtitude, forKey: "longtitude")
        
        let data = imageLabel.image?.jpegData(compressionQuality: 0.5)
        newPlace.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

}
