//
//  MapViewController.swift
//  MyLocations
//
//  Created by Lennart Erikson on 02/02/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    // MARK: - IBActions
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showLocations() {
        
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entitiy = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        let fetchRequest = NSFetchRequest()

        fetchRequest.entity = entitiy
        
        locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]
        mapView.addAnnotations(locations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLocations()
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
}
