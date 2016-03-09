//
//  SpeciesModel.swift
//  SISpeciesNotes
//
//  Created by Semper_Idem on 15/12/3.
//  Copyright © 2015年 益行人. All rights reserved.
//

import UIKit
import RealmSwift

class SpeciesModel: Object {
    dynamic var name = ""
    dynamic var speciesDescription: String?
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var created = NSDate()
    dynamic var category: CategoryModel?
    /// The distance between this animal and user
    dynamic var distance: Double = 0
    
    override static func ignoredProperties() -> [String] {
        return ["distance"]
    }
}
