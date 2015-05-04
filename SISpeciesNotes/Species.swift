//
//  Species.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-30.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import Realm

class SpeciesModel: RLMObject {
    dynamic var name = ""
    dynamic var speciesDescription = ""
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var created = NSDate()
    dynamic var category = CategoryModel()
    dynamic var distance: Double = 0
    
    func ignoredProperties() -> NSArray {
        let propertiesToIgnore = [distance]
        return propertiesToIgnore
    }
}