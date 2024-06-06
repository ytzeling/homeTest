//
//  ShimmerViewController.swift
//  github
//
//  Created by Yong Tze Ling on 06/06/2024.
//

import UIKit
import ShimmerSwift


class ShimmerView: UIView, UITableViewDelegate, UITableViewDataSource {

    private let tableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.register(ShimmerCell.self, forCellReuseIdentifier: "ShimmerCell")
        return tableview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath) as! ShimmerCell
        return cell
    }
}

class ShimmerCell: UITableViewCell {
    
    private let shimmerAvatar = {
        let view = ShimmeringView(frame: .init(origin: .zero, size: CGSize(width: 50, height: 50)))
        let image = UIView(frame: view.bounds)
        image.backgroundColor = .gray
        image.layer.cornerRadius = 25
        view.contentView = image
        view.isShimmering = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textView = {
        let view = ShimmeringView(frame: .zero)
        let text = UIView(frame: view.bounds)
        text.backgroundColor = .gray
        view.contentView = text
        view.isShimmering = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 16
        stackview.distribution = .fill
        stackview.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackview)
        stackview.addArrangedSubview(shimmerAvatar)
        stackview.addArrangedSubview(textView)
        
        NSLayoutConstraint.activate([
            stackview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            stackview.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            stackview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            stackview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            shimmerAvatar.heightAnchor.constraint(equalToConstant: 50),
            shimmerAvatar.widthAnchor.constraint(equalToConstant: 50),
            textView.leadingAnchor.constraint(equalTo: shimmerAvatar.trailingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: stackview.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
