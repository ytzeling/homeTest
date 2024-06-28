//
//  CoreDataStack.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "github")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private init() {
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchUsers(completion: @escaping ([User]?) -> Void) {
        let fetchRequest = User.fetchRequest()
        do {
            let users = try self.mainContext.fetch(fetchRequest)
            completion(users)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUser(_ username: String) -> User? {
        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", username)
        do {
            let user = try self.mainContext.fetch(fetchRequest).first
            return user
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func updateUserNote(_ username: String, note: String?) {
        
        persistentContainerQueue.addOperation {
            self.persistentContainer.performBackgroundTask { context in
                do {
                    let fetchRequest = User.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "login == %@", username)
                    
                    let users = try context.fetch(fetchRequest)
                    if let user = users.first {
                        user.note = note
                        try context.save()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    func seenProfile(_ username: String) {
        persistentContainerQueue.addOperation {
            self.persistentContainer.performBackgroundTask { context in
                do {
                    let fetchRequest = User.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "login == %@", username)
                    
                    let users = try context.fetch(fetchRequest)
                    if let user = users.first, user.seen == false {
                        user.seen = true
                        try context.save()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func storeData(data: Data) {
        persistentContainerQueue.addOperation {
            self.persistentContainer.performBackgroundTask { context in
                do {
                    let decoder = JSONDecoder(context: context)
                    _ = try decoder.decode([User].self, from: data)
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
