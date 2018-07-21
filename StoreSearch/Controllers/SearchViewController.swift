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

    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "App name, artist, song, album, e-book"
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let searchResultCellID = "searchResults"
    private let nothingFoundCellID = "nothingFound"
    var searchResults = [SearchResult]()
    var hasSearched = false

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI

    func setupUI() {
        searchBar.becomeFirstResponder()
        searchTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: searchResultCellID)
        searchTableView.register(NothingFoundCell.self, forCellReuseIdentifier: nothingFoundCellID)
        view.backgroundColor = .white
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.delegate = self
        view.addSubview(searchTableView)
        searchTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchTableView.dataSource = self
        searchTableView.delegate = self
    }
}

// MARK: - search bar delegate methods

extension SearchViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        if searchBar.text != "Justin Bieber" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = "Fake Result #\(i + 1)"
                searchResult.artistName = searchBar.text ?? ""
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        searchTableView.reloadData()
        searchBar.resignFirstResponder()
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - table view delegate methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return searchResults.count == 0 ? nil : indexPath
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: nothingFoundCellID, for: indexPath)
        } else {
            let cell = searchTableView.dequeueReusableCell(withIdentifier: searchResultCellID) as! SearchTableViewCell
            let searchResult = searchResults[indexPath.row]
            cell.topLabel.text = searchResult.name
            cell.bottomLabel.text = searchResult.artistName
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else {
            return searchResults.count == 0 ? 1 : searchResults.count
        }
    }

}










