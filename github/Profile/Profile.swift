//
//  Profile.swift
//  github
//
//  Created by Yong Tze Ling on 28/06/2024.
//

import Foundation

struct Profile: Decodable {
    
    let name: String?
    let company: String?
    let followers: Int
    let following: Int
}
