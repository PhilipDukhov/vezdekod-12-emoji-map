//
//  Post.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import Foundation
import CoreLocation
import SwiftyUserDefaults

struct Post: Codable, DefaultsSerializable {
    let topic: Topic
    private let latitude: CLLocationDegrees
    private let longitude: CLLocationDegrees
    var location: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude)}
    
    init(topic: Topic, location: CLLocationCoordinate2D) {
        self.topic = topic
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
}

