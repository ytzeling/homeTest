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
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
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
