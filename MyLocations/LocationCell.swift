//
//  LocationCell.swift
//  MyLocations
//
//  Created by Lennart Erikson on 02/02/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellForLocation(location: Location) {
        
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s + ", "
            }
            
            adressLabel.text = text
        } else {
            adressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.logitude)
        }
        
        photoImageView.image = imageForLocation(location)
    }
    
    func imageForLocation(location: Location) -> UIImage {

        if location.hasPhoto, let image = location.photoImage {
            return image
        }
        return UIImage()
    }

}
