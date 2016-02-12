//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Lennart Erikson on 29/01/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = NSDate()
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.hidden = false
                imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
                addPhotoLabel.hidden = true
            }
        }
    }
    var observer: AnyObject!
    
    // Using a property observer here is clean!
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.logitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    var managedObjectContext: NSManagedObjectContext!
    
    // lazy loaded NSDateFormatter object
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        
        return formatter
    }()
    
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit location"
            
            if location.hasPhoto {
                if let image = location.photoImage {
                    imageView.image = image
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            adressLabel.text = stringFromPlacemark(placemark)
        } else {
            adressLabel.text = "No Adress Found"
        }
        
        dateLabel.text = formatDate(date)
        categoryLabel.text = categoryName
        
        // Customize tableViews appearance
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        
        descriptionTextView.textColor = UIColor.whiteColor()
        descriptionTextView.backgroundColor = UIColor.blackColor()
        
        addPhotoLabel.textColor = UIColor.whiteColor()
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        
        adressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        adressLabel.highlightedTextColor = adressLabel.textColor
        
        
        
        // Used to improve usabillity and hide keyboard when user taps anywhere on the screen
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Business logic
    func hideKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath?.section == 0 && indexPath?.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var text = ""
        
        text.addText(placemark.subThoroughfare)
        text.addText(placemark.thoroughfare, withSeparator: " ")
        text.addText(placemark.locality, withSeparator: ", ")
        text.addText(placemark.administrativeArea, withSeparator: ", ")
        text.addText(placemark.postalCode, withSeparator: " ")
        text.addText(placemark.country, withSeparator: ", ")
        
        return text
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            
            return 88
        case (1, _):
            
            return imageView.hidden ? 44 : 280
        case (2, 2):
            
            // Calculate the size of the label
            adressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            adressLabel.sizeToFit()
            
            // Calculate the position
            adressLabel.frame.origin.x = view.bounds.size.width - adressLabel.frame.size.width  - 15
            return adressLabel.frame.size.height + 20
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.blackColor()
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
        
        if indexPath.row == 2 {
            let adressLabel = cell.viewWithTag(100) as! UILabel
            adressLabel.textColor = UIColor.whiteColor()
            adressLabel.highlightedTextColor = adressLabel.textColor
        }
    }
    
    // MARK: - IBAction
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        let location: Location
        
        // Only create a new location when it did not exist already
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
            location.photoID = nil
        }
        
        
        // Core Location saving action
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.logitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                
                do {
                    try data.writeToFile(location.photoPath, options: .DataWritingAtomic)
                } catch {
                    print("Error writing to file \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        // Use GCD to dismiss the ViewController
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategorySegue" {
            let pickVC = segue.destinationViewController as! CategoryPickerViewController
            pickVC.selectedCategoryName = categoryName
        }
    }
    
    // MARK: Required for Unwind-Segue from CategoryPicker!
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(true, completion: nil)
                }
                
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

}

// MARK: - UIImagePickerControllerDelegate + UINavigationControllerDelegate Extension
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePictureFromCameraRoll()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { _ in
            self.takePictureWithCamera()
        }
        
        alertController.addAction(takePhotoAction)
        
        let chooseFromCameraRollAction = UIAlertAction(title: "Choose from library", style: .Default) { _ in
            self.choosePictureFromCameraRoll()
        }
        
        alertController.addAction(chooseFromCameraRollAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func takePictureWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePictureFromCameraRoll() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
