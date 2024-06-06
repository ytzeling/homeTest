//
//  ProfileViewController.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import UIKit
import SwiftUI

class ProfileViewController: UIViewController {

    var username: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let profile = ProfileView(username: username)
        
        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: profile))
        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds
        navigationController.didMove(toParent: self)
    }

}
