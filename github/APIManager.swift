//
//  APIManager.swift
//  github
//
//  Created by Yong Tze Ling on 05/06/2024.
//

import Foundation

class APIManager {
    
    let serialQueue = DispatchQueue(label: "com.github.networkQueue")
    
    static let shared = APIManager()
    
    func fetchUsers(lastSince: Int, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://api.github.com/users?since=\(lastSince)") else {
            completion(.failure(.invalidUrl))
            return
        }
        
        serialQueue.async {
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(.emptyData))
                    return
                }
                
                CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
                    do {
                        let decoder = JSONDecoder(context: context)
                        _ = try decoder.decode([User].self, from: data)
                        try context.save()
                        
                        completion(.success(true))

                    } catch {
                        print(error.localizedDescription)
                        completion(.failure(.error(error)))
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func fetchUser(username: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            completion(.failure(.invalidUrl))
            return
        }
        
        serialQueue.async {
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(.emptyData))
                    return
                }
                
                do {
                    let user = try JSONDecoder().decode(Profile.self, from: data)
                    let fetchRequest = User.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "login == %@", username)
                    
                    let context = CoreDataStack.shared.mainContext
                    if let existingUser = try context.fetch(fetchRequest).first {
                        existingUser.company = user.company
                        existingUser.name = user.name
                        existingUser.followers = Int16(user.followers)
                        existingUser.following = Int16(user.following)
                        
                        try context.save()
                        
                        completion(.success(existingUser))
                    }
                    
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(.error(error)))
                }
                
            }
            
            task.resume()
        }
    }
}

enum NetworkError: Error {
    case invalidUrl
    case error(Error)
    case emptyData
}
