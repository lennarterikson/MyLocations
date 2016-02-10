//
//  String+AddText.swift
//  MyLocations
//
//  Created by Lennart Erikson on 10/02/16.
//  Copyright © 2016 Lennart Erikson. All rights reserved.
//

import UIKit

extension String {
    mutating func addText(text: String?, withSeparator separator: String = "") {
        
        if let text = text {
            
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
