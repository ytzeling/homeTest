//
//  User+CoreDataClass.swift
//  github
//
//  Created by Yong Tze Ling on 31/05/2024.
//
//

import Foundation
import CoreData

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}


public class User: NSManagedObject, Decodable {

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let login = try container.decode(String.self, forKey: .login)

        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        
        let existingUsers = try context.fetch(fetchRequest)
        if let _ = existingUsers.first {
            self.init(entity: entity, insertInto: nil)
        } else {
            self.init(entity: entity, insertInto: context)
            self.id = try container.decode(Int16.self, forKey: .id)
            self.login = login
            self.avartarUrl = try container.decodeIfPresent(String.self, forKey: .avartarUrl)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, login, followers, following, company
        case avartarUrl = "avatar_url"
    }
    
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[CodingUserInfoKey.managedObjectContext] = context
    }
}
