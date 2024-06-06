//
//  User+CoreDataProperties.swift
//  github
//
//  Created by Yong Tze Ling on 05/06/2024.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var avartarUrl: String?
    @NSManaged public var company: String?
    @NSManaged public var followers: Int16
    @NSManaged public var following: Int16
    @NSManaged public var id: Int16
    @NSManaged public var login: String
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var seen: Bool

}

extension User : Identifiable {

}
