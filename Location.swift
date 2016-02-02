//
//  Location.swift
//  MyLocations
//
//  Created by Lennart Erikson on 31/01/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Location: NSManagedObject, MKAnnotation {

    // MKAnnotation conformation
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, logitude)
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String? {
        return category
    }

}
