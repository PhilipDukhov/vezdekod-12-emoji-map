//
//  DefaultsKeys.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var posts: DefaultsKey<[Post]> { .init(#function, defaultValue: []) }
}
