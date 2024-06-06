//
//  UsersViewController.swift
//  github
//
//  Created by Yong Tze Ling on 30/05/2024.
//

import UIKit
import CoreData
import Toast
import Reachability

class UsersViewController: UIViewController {

    private lazy var viewModel = {
        let vm = UsersViewModel()
        vm.fetchedResultsDelegate = self
        return vm
    }()
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NormalCell.self, forCellReuseIdentifier: "NormalCell")
        tableView.register(InvertedCell.self, forCellReuseIdentifier: "InvertedCell")
        tableView.refreshControl = UIRefreshControl()
        return tableView
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()
    
    private let searchBar: UISearchBar = {
       let searchbar = UISearchBar()
        searchbar.placeholder = "Search User"
        searchbar.showsCancelButton = true
        return searchbar
    }()
    
    private let offlineIndicator = OfflineView()
    
    private let shimmerView = { 
        let view = ShimmerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(offlineIndicator)
        view.addSubview(shimmerView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.tableFooterView = self.loadingView
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            offlineIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineIndicator.heightAnchor.constraint(equalToConstant: 40),
            shimmerView.topAnchor.constraint(equalTo: view.topAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        viewModel.onShowOfflineIndicator = { [weak self] show in
            DispatchQueue.main.async {
                self?.offlineIndicator.isHidden = !show
            }
        }
        
        viewModel.onReloadTable = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if (self.shimmerView.isHidden == false) {
                    self.shimmerView.isHidden = true
                }
                
                self.tableView.reloadData()
                if self.tableView.refreshControl?.isRefreshing == true {
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    @objc func pullToRefresh() {
        viewModel.refreshUsers()
    }
    
    @objc func contextSaved(_ notification: Notification) {
        viewModel.fetchedResultsController.managedObjectContext.mergeChanges(fromContextDidSave: notification)
        viewModel.fetchedResultsController.managedObjectContext.processPendingChanges()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = viewModel.user(at: indexPath.row) {
            let vc = ProfileViewController()
            vc.username = user.login
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellViewModel = viewModel.viewModel(for: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath) as! BaseCell
            cell.populate(with: cellViewModel)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userCount
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            if !viewModel.isSearching {
                loadingView.startAnimating()
            } else {
                loadingView.stopAnimating()
            }
        }
    }
}

extension UsersViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row == viewModel.userCount - 1 {
            viewModel.loadMoreUsers()
        }
    }
}

extension UsersViewController: UISearchBarDelegate {
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            viewModel.searchUser(keyword: searchText) { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.clearSearchResults()
        tableView.reloadData()
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

extension UsersViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
}
