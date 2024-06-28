//
//  UsersViewModel.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import Foundation
import CoreData
import Reachability

class UsersViewModel: NSObject {
    
    var lastSince: Int = 0
    
    var updateTableContent: ((NSFetchedResultsChangeType, IndexPath) -> Void)?
    
    lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = fetchedResultsDelegate
        return fetchedResultsController
    }()
    
    var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    var userCount: Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    var onNetworkChanged: ((Bool) -> Void)?
    var onReloadTable: (() -> Void)?
    
    let reachability = try! Reachability()
    
    private var isLoading = false
    var isSearching: Bool = false
    
    override init() {
        super.init()
        do {
            try reachability.startNotifier()
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    func user(at index: Int) -> User? {
        return fetchedResultsController.fetchedObjects?[index]
    }
    
    func fetchUsers() {
        
        if reachability.connection != .unavailable {
            isLoading = true
            
            APIManager.shared.fetchUsers(lastSince: self.lastSince) { [weak self] result in
                
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let success):
                    
                    do {
                        try self.fetchedResultsController.performFetch()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    self.isLoading = false
                    self.lastSince = Int(self.fetchedResultsController.fetchedObjects?.last?.id ?? 0)
                    self.onReloadTable?()
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        } else {
            self.onReloadTable?()
        }
    }
    
    func refreshUsers() {
        guard !isLoading else { return }
        lastSince = 0
        fetchUsers()
    }
    
    func loadMoreUsers() {
        guard !isLoading else { return }
        fetchUsers()
    }
    
    func searchUser(keyword: String, completion: @escaping (() -> Void?)) {
        isSearching = true
        let predicate = NSPredicate(format: "(login CONTAINS[c] %@) || (note CONTAINS[c] %@)", keyword, keyword)
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        completion()
    }
    
    func clearSearchResults() {
        isSearching = false
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        onNetworkChanged?(reachability.connection == .unavailable)
    }
    
    func viewModel(for index: Int) -> TableViewCellModelProtocol? {
        guard let user = user(at: index) else {
            return nil
        }
        
        if (index % 4 == 3) {
            return InvertedCellModel(name: user.login, avatarUrl: user.avartarUrl, note: user.note, seen: user.seen)
        } else {
            return NormalCellModel(name: user.login, avatarUrl: user.avartarUrl, note: user.note, seen: user.seen)
        }
    }
}
