//
//  OfflineView.swift
//  github
//
//  Created by Yong Tze Ling on 03/06/2024.
//

import UIKit

class OfflineView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.text = "No Internet Connection"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .red.withAlphaComponent(0.4)
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
