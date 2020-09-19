//
//  Post.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import Foundation
import CoreLocation
import SwiftyUserDefaults
import MapKit

struct Post: Codable, DefaultsSerializable, Equatable {
    let topic: Topic
    private let latitude: CLLocationDegrees
    private let longitude: CLLocationDegrees
    var location: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude)}
    var mapPoint: MKMapPoint { .init(location) }
    
    let clusterCount: Int
    
    init(topic: Topic, location: CLLocationCoordinate2D, clusterCount: Int = 1) {
        self.topic = topic
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.clusterCount = clusterCount
    }
}
