//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Lennart Erikson on 28/01/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit
import CoreData

// Fail notification
let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: ErrorType) {
    print("*** Fatal Error: \(error)")
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    // Used in every CoreData App!!!
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from \(modelURL)")
        }
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = urls[0]
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        do {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        
        } catch {
            fatalError("Error adding persistence store at: \(storeURL): \(error)")
        }
    }()

    var window: UIWindow?
    
    // Listen for fail notifications
    func listenForFatalCoreDataNotification() {
        
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            let alert = UIAlertController(title: "Internal Error", message: "We're sorry, but we could not save your location!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: { (_) -> Void in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise()
            })
            
            alert.addAction(action)
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        }
    }

    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = window!.rootViewController!
        
        if let presentedVC = rootViewController.presentedViewController {
            return presentedVC
        } else {
            return rootViewController
        }
    }
    
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UITabBar.appearance().barTintColor = UIColor.blackColor()
        
        let tintColor = UIColor(red: 255/255, green: 238/255, blue: 136/255, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            let locNavVC = tabBarViewControllers[1] as! UINavigationController
            let locationsVC = locNavVC.topViewController as! LocationsViewController
            
            locationsVC.managedObjectContext = managedObjectContext
            
            // Fix for a bug in iOS 9 & Core Data, forces fetchedResultsController to load when app starts
            let _ = locationsVC.view
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            
        }
        
        customizeAppearance()
        listenForFatalCoreDataNotification()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

