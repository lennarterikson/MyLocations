//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Lennart Erikson on 28/01/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - iVars
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    var timer: NSTimer?
    var managedObjectContext: NSManagedObjectContext!
    var soundID: SystemSoundID = 0
    
    // for animation purposes
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
        button.sizeToFit()
        button.addTarget(self, action: Selector("getLocation"), forControlEvents: .TouchUpInside)
        button.center.x = CGRectGetMidX(self.view.bounds)
        button.center.y = 220
        
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        loadSoundEffect("Sound.caf")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Logo View
    func showLogoView() {
        
        if !logoVisible {
            logoVisible = true
            containerView.hidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        
        if !logoVisible { return }
        
        logoVisible = false
        containerView.hidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        let centerX = CGRectGetMidX(view.bounds)
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.removedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(CGPoint: containerView.center)
        panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y))
        
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.addAnimation(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.removedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(CGPoint: logoButton.center)
        logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
        
        let logoRotater = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotater.removedOnCompletion = false
        logoRotater.fillMode = kCAFillModeForwards
        logoRotater.duration = 0.5
        logoRotater.fromValue = 0.0
        logoRotater.toValue = -2 * M_PI
        logoRotater.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        logoButton.layer.addAnimation(logoRotater, forKey: "logoRotator")
        
        
        
        logoButton.removeFromSuperview()
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + view.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    // MARK: - IBActions
    @IBAction func getLocation(sender: UIButton) {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            placemark = nil
            lastLocationError = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        if logoVisible {
            hideLogoView()
        }
        
        updateLabels()
        configureGetButton()
    }
    
    // MARK: - Business logic
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Denied", message: "This App needs permission to use your location, please enable this in settings.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            latitudeTextLabel.hidden = false
            longitudeTextLabel.hidden = false
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            adressLabel.text = ""
            tagButton.hidden = true
            latitudeTextLabel.hidden = true
            longitudeTextLabel.hidden = true
            
        }
        
        let statusMessage: String
        if let error = lastLocationError {
            if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                statusMessage = "Location Services Disabled"
            } else {
                statusMessage = "Error Getting Location!"
            }
        } else if !CLLocationManager.locationServicesEnabled(){
            statusMessage = "Location Services Disabled"
        } else if updatingLocation {
            statusMessage = "Searching..."
        } else {
            statusMessage = ""
            showLogoView()
        }
        messageLabel.text = statusMessage

        
        if let placemark = placemark {
            adressLabel.text = stringFromPlacemark(placemark)
        } else if performingReverseGeocoding {
            adressLabel.text = "Searching For Adress..."
        } else if lastGeocodingError != nil {
            adressLabel.text = "Error Finding Adress!"
        } else {
            adressLabel.text = "No Adress Found"
        }
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        var line1 = ""
        
        line1.addText(placemark.subThoroughfare)
        line1.addText(placemark.thoroughfare, withSeparator: " ")
        
        var line2 = ""
        
        line2.addText(placemark.locality)
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        line2.addText(placemark.postalCode, withSeparator: " ")
        
        line1.addText(line2, withSeparator: "\n")
        
        return line1
    }
    
    
    
    func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        
        if updatingLocation {
            updatingLocation = false
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func didTimeOut() {
        
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetButton()
        }
    }
    
    func configureGetButton() {
        
        let spinnerTag = 1000
        
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
            
            if view.viewWithTag(spinnerTag) == nil {

                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.height / 2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
                
            }
        } else {
            getButton.setTitle("Get my location", forState: .Normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     
        let newLocation = locations.last!
        
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location?.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            // Reverse Geocoding starts here
            if !performingReverseGeocoding {
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {placemarks, error in
                    
                    self.lastLocationError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                        
                        if self.placemark == nil {
                            print("First time!")
                            self.playSoundEffect()
                        }
                        
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance > 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TagLocationSegue" {
            let navVC = segue.destinationViewController as! UINavigationController
            let tagVC = navVC.topViewController as! LocationDetailsViewController
            
            tagVC.coordinate = location!.coordinate
            tagVC.placemark = placemark
            tagVC.managedObjectContext = managedObjectContext
        }
        
    }
    
    // MARK: - Sound Effect
    func loadSoundEffect(name: String) {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
            
            let fileURL = NSURL.fileURLWithPath(path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
            
            if error != kAudioServicesNoError {
                print("Error loading sound: \(error)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlayAlertSound(soundID)
    }
    


}

