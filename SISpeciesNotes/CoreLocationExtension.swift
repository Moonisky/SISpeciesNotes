//
//  CoreLocationExtension.swift
//  SISpeciesNotes
//
//  Created by Semper_Idem on 16/1/11.
//  Copyright © 2016年 益行人. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable { }

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
