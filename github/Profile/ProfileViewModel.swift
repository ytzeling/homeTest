//
//  ProfileViewModel.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import SwiftUI
import Reachability

class ProfileViewModel: ObservableObject {
    
    var username: String = ""
    
    @Published var userData: User?
    @Published var noteText: String = ""
    
    let reachability = try! Reachability()
    
    init(username: String) {
        self.username = username
    }
    
    func fetchData() {
        if reachability.connection != .unavailable {
            APIManager.shared.fetchUser(username: self.username) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        self.noteText = user.note ?? ""
                        self.userData = user
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        } else {
            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "login == %@", self.username)
            
            let context = CoreDataStack.shared.mainContext
            do {
                if let existingUser = try context.fetch(fetchRequest).first {
                    DispatchQueue.main.async {
                        self.noteText = existingUser.note ?? ""
                        self.userData = existingUser
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    func saveNote() {
        CoreDataStack.shared.updateUserNote(username, note: noteText)
    }
    
    func seenProfile() {
        CoreDataStack.shared.seenProfile(username)
    }
    
    var followers: String {
        return "followers: \(userData?.followers ?? 0)"
    }
    
    var followings: String {
        return "following: \(userData?.following ?? 0)"
    }
    
    var name: String {
        return "name: \(userData?.name ?? "")"
    }
    
    var company: String {
        return "company: \(userData?.company ?? "")"
    }
    
    var imageUrl: String {
        return userData?.avartarUrl ?? ""
    }
    
}
