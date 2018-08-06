//
//  Item.swift
//  TodoKids
//
//  Created by Khoa Vo on 8/6/18.
//  Copyright © 2018 Expert-Generalist. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title = "unnamed"
    @objc dynamic var done = false
    @objc dynamic var date: Date?
    var parentCategory: LinkingObjects<Category>?
}
