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
    private let loadingCellID = "loading"
    private let searchResultCellID = "searchResults"
    private let nothingFoundCellID = "nothingFound"
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func iTunesURL(searchTerm: String) -> URL {
        let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedTerm)
        return URL(string: urlString)!
    }

    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Parsing Error: \(error.localizedDescription)")
            return []
        }
    }

    func performSearchRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }

    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes store." +
            " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UI

    private func setupUI() {
        searchBar.becomeFirstResponder()
        searchTableView.register(LoadingCell.self, forCellReuseIdentifier: loadingCellID)
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
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        isLoading = true
        searchTableView.reloadData()
        hasSearched = true
        searchResults = []
        let queue = DispatchQueue.global()
        queue.async {
            let url = self.iTunesURL(searchTerm: searchText)
            if let data = self.performSearchRequest(with: url) {
                self.searchResults = self.parse(data: data)
                self.searchResults.sort(by: <)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.searchTableView.reloadData()
                }
                return
            }
        }
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
        return (searchResults.count == 0 || isLoading) ? nil : indexPath
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellID, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: nothingFoundCellID, for: indexPath) 
        } else {
            let cell = searchTableView.dequeueReusableCell(withIdentifier: searchResultCellID) as! SearchTableViewCell
            let searchResult = searchResults[indexPath.row]
            cell.topLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.bottomLabel.text = "Unknown"
            } else {
                cell.bottomLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.type)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else {
            return searchResults.count == 0 ? 1 : searchResults.count
        }
    }

}










