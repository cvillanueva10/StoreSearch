//
//  Search.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 8/1/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void
class Search {

    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3

        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    private(set) var state: State = .notSearchedYet
    private var dataTask: URLSessionDataTask? = nil

    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        guard !text.isEmpty else { return }
        dataTask?.cancel()
        state = .loading
        let url = iTunesURL(searchTerm: text, category: category)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { (data, response, error) in
            var newState: State = .notSearchedYet
            var success = false
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200, let data = data {
                print("Successful!")
                var searchResults = self.parse(data: data)
                if searchResults.isEmpty {
                    newState = .noResults
                } else {
                    searchResults.sort(by: <)
                    newState = .results(searchResults)
                }
                success = true
            }
            DispatchQueue.main.async {
                self.state = newState
                completion(success)
            }
        }
        dataTask?.resume()
    }

    private func iTunesURL(searchTerm: String, category: Category) -> URL {
        let kind = category.type
        let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&limit=200&entity=\(kind)"
        return URL(string: urlString)!
    }

    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Parsing Error: \(error.localizedDescription)")
            return []
        }
    }

}
