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
        
        backgroundColor  = UIColor.blackColor()
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        adressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        adressLabel.highlightedTextColor = adressLabel.textColor
        
        // Custom selection view
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        // Make the image thumbnail round
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        
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
            
            text.addText(placemark.subThoroughfare)
            text.addText(placemark.thoroughfare, withSeparator: " ")
            text.addText(placemark.locality, withSeparator: ", ")
            
            
            adressLabel.text = text
        } else {
            adressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.logitude)
        }
        
        photoImageView.image = imageForLocation(location)
    }
    
    func imageForLocation(location: Location) -> UIImage {

        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
        }
        return UIImage(named: "No Photo")!
    }

}
