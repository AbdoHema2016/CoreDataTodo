//
//  Category.swift
//  CoreDataTodo
//
//  Created by Abdelrahman-Arw on 12/22/19.
//  Copyright © 2019 Abdelrahman-Arw. All rights reserved.
//

import Foundation
import RealmSwift
class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
