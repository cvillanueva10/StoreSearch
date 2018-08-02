//
//  ViewController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/17/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - properties

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "App name, artist, song, album, e-book"
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    private let searchSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "All", at: 0, animated: true)
        control.insertSegment(withTitle: "Music", at: 1, animated: true)
        control.insertSegment(withTitle: "Software", at: 2, animated: true)
        control.insertSegment(withTitle: "E-books", at: 3, animated: true)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let loadingCellID = "loading"
    private let searchResultCellID = "searchResults"
    private let nothingFoundCellID = "nothingFound"
    private let search = Search()
    var landscapeViewController: LandscapeViewController?

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange,
                                               object: .none,
                                               queue: OperationQueue.main) { [weak self] _ in
                                                self?.searchTableView.reloadData()
        }
        searchTableView.rowHeight = UITableViewAutomaticDimension
        searchTableView.estimatedRowHeight = 80
        setupUI()
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }

    // MARK: - networking

    @objc func performSearch() {
        guard let searchText = searchBar.text else { return }
        search.performSearch(for: searchText, category: searchSegmentedControl.selectedSegmentIndex) { (success) in
            if !success {
                self.showNetworkError()
            } else {
                self.searchTableView.reloadData()
            }
        }
        searchTableView.reloadData()
        searchBar.resignFirstResponder()
    }

    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes store." +
            " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UI

    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else { return }
        landscapeViewController = LandscapeViewController()
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChildViewController(controller)
            controller.didMove(toParentViewController: self)
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (_) in
                controller.didMove(toParentViewController: self)
            }
        }
    }

    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil)
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 0
            }) { (_) in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(white: 1, alpha: 0.95)
        searchBar.becomeFirstResponder()
        searchTableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCellID)
        searchTableView.register(SearchResultCell.self, forCellReuseIdentifier: searchResultCellID)
        searchTableView.register(NothingFoundCell.self, forCellReuseIdentifier: nothingFoundCellID)
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.delegate = self
        view.addSubview(searchSegmentedControl)
        searchSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8).isActive = true
        searchSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchSegmentedControl.widthAnchor.constraint(equalToConstant: 300).isActive = true
        searchSegmentedControl.addTarget(self, action: #selector(performSearch), for: .valueChanged)
        view.addSubview(searchTableView)
        searchTableView.topAnchor.constraint(equalTo: searchSegmentedControl.bottomAnchor, constant: 8).isActive = true
        searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchTableView.dataSource = self
        searchTableView.delegate = self
        view.addSubview(separatorView)
        separatorView.bottomAnchor.constraint(equalTo: searchTableView.topAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

// MARK: - search bar delegate methods

extension SearchViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - table view delegate methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewController = DetailViewController()
        detailViewController.searchResult = search.searchResults[indexPath.item]
        present(detailViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (search.searchResults.count == 0 || search.isLoading) ? nil : indexPath
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellID, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: nothingFoundCellID, for: indexPath) 
        } else {
            let cell = searchTableView.dequeueReusableCell(withIdentifier: searchResultCellID) as! SearchResultCell
            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else {
            return search.searchResults.count == 0 ? 1 : search.searchResults.count
        }
    }
}


