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
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?

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

    // MARK: - networking

    func iTunesURL(searchTerm: String, category: Int) -> URL {
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&limit=200&entity=\(kind)"
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


    @objc func performSearch() {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        dataTask?.cancel()
        isLoading = true
        searchTableView.reloadData()
        hasSearched = true
        searchResults = []
        let url = iTunesURL(searchTerm: searchText, category: searchSegmentedControl.selectedSegmentIndex)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
                if let data = data {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.searchTableView.reloadData()
                    }
                    return
                }
            } else {
                print("Failure! \(response!)")
            }
            DispatchQueue.main.async {
                self.hasSearched = false
                self.isLoading = false
                self.searchTableView.reloadData()
                self.showNetworkError()
            }
        }
        dataTask?.resume()
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
        detailViewController.searchResult = searchResults[indexPath.item]
        present(detailViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (searchResults.count == 0 || isLoading) ? nil : indexPath
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }

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
            let cell = searchTableView.dequeueReusableCell(withIdentifier: searchResultCellID) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
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


