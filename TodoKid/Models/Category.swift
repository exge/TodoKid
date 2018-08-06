//
//  Category.swift
//  TodoKids
//
//  Created by Khoa Vo on 8/5/18.
//  Copyright © 2018 Expert-Generalist. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = "unnamed";
    @objc dynamic var color = "#FFFFFF";
    let childrenItems = List<Item>()
}
