//
//  ViewControllerIAM.swift
//  IamHereApp
//
//  Created by Yavuz Ulgar on 12.01.2023.
//

import UIKit
import MapKit
import CoreData

class ViewControllerIAM: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectedId : UUID?
    var annotationLatitude = Double()
    var annotationLongtitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        mapView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        let idString = selectedId?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        titleLabel.text = title
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageLabel.image = image
                            if let latitude = result.value(forKey: "latitude") as? Double {
                                annotationLatitude = latitude
                                if let longtitude = result.value(forKey: "longtitude") as? Double {
                                    annotationLongtitude = longtitude
                                    
                                    let annotation = MKPointAnnotation()
                                    annotation.title = titleLabel.text
                                    let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongtitude)
                                    annotation.coordinate = coordinate
                                    
                                    mapView.addAnnotation(annotation)
                                    
                                    let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    mapView.setRegion(region, animated: true)
                                    
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation {
                return nil
            }
            
            let reuseId = "myAnnotation"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.canShowCallout = true
                pinView?.tintColor = UIColor.black
                
                let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
                pinView?.rightCalloutAccessoryView = button
                
            } else {
                pinView?.annotation = annotation
            }

            return pinView
        }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongtitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.titleLabel.text
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
        }
    }
}
