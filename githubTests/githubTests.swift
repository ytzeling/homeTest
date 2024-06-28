//
//  githubTests.swift
//  githubTests
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import XCTest
import CoreData

@testable import github

final class githubTests: XCTestCase {
    
    var sut: UsersViewModel?
    var coreDataStack: CoreDataTestStack!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func setUp() {
        sut = UsersViewModel()
        coreDataStack = CoreDataTestStack()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
    }
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testFetchedResultsControllerFetch() {
        let context = coreDataStack.context
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        for i in 0..<10 {
            let object = NSManagedObject(entity: entity, insertInto: context)
            object.setValue(i, forKey: "id")
            object.setValue("username", forKey: "login")
        }
        
        do {
            try context.save()
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 10, "Fetch did not return the correct number of objects")
    }
    
    
    func testCreateUser() {
        let context = coreDataStack.context
        let user = User(context: context)
        user.id = 1
        user.login = "username"
        user.avartarUrl = "link"
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            XCTAssertEqual(result.count, 1, "There should be one user")
            XCTAssertEqual(result.first?.id, 1, "The user's id should be '1'")
            XCTAssertEqual(result.first?.avartarUrl, "link", "The user's avatarUrl should be 'link'")
            XCTAssertEqual(result.first?.login, "username", "The user's login should be 'username'")
            XCTAssertNil(result.first?.note, "The user's note should be empty")
            XCTAssertTrue(result.first?.seen == false, "The user's seen indicator is false")
            XCTAssertNil(result.first?.company, "The user's company should be empty")
            XCTAssertNil(result.first?.name, "The user's name should be empty")
        } catch {
            XCTFail("Failed to fetch context: \(error)")
        }
    }
    
    func testUpdateNote() {
        let context = coreDataStack.context
        let user = User(context: context)
        user.id = 1
        user.login = "username"
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        user.name = "name"
        user.note = "test note"
        user.seen = true
        user.company = "company"
        user.followers = 100
        user.following = 200
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.note, "test note", "The user's note should be 'test note'")
            XCTAssertEqual(result.first?.name, "name", "The user's name should be 'name'")
            XCTAssertEqual(result.first?.company, "company", "The user's company should be 'company'")
            XCTAssertTrue(result.first?.seen == true)
            XCTAssertEqual(result.first?.followers, 100, "The user's followers should be 100")
            XCTAssertEqual(result.first?.following, 200, "The user's following should be 200")
        } catch {
            XCTFail("Failed to fetch context: \(error)")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    override func tearDown() {
        fetchedResultsController = nil
        coreDataStack = nil
        sut = nil
        super.tearDown()
    }
    
}

extension githubTests: NSFetchedResultsControllerDelegate {
    
}

class CoreDataTestStack {
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "github")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { description, error in
            assert(error == nil, error.debugDescription.localizedLowercase)
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
