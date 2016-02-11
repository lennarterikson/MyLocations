//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Lennart Erikson on 11/02/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
