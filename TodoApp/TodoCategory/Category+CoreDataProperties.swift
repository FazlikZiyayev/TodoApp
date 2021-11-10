//
//  Category+CoreDataProperties.swift
//  TodoApp
//
//  Created by Fazlik Ziyaev on 10/11/21.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?

}

extension Category : Identifiable {

}
