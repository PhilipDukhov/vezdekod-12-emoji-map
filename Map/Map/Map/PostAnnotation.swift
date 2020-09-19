//
//  MapAnnotation.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    let post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var coordinate: CLLocationCoordinate2D { post.location }
    var title: String?
    var subtitle: String?
}
