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
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoPath: String {
        assert(photoID != nil, "No photoID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return (applicationDocumentsDirectory as NSString).stringByAppendingPathComponent(filename)
    }

    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID")
        
        userDefaults.setInteger(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        
        if hasPhoto {
            let path = photoPath
            let filemanager = NSFileManager.defaultManager()
            
            if filemanager.fileExistsAtPath(path) {
                
                do {
                    try filemanager.removeItemAtPath(path)
                } catch {
                    print("Error removing file: \(error)")
                }
            }
        }
    }
}
