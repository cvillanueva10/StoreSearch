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

    var searchResults: [SearchResult] = []
    var hasSearched = false
    var isLoading = false
    private var dataTask: URLSessionDataTask? = nil

    func performSearch(for text: String, category: Int, completion: @escaping SearchComplete) {
        guard !text.isEmpty else { return }
        dataTask?.cancel()
        isLoading = true
        hasSearched = true
        searchResults = []
        let url = iTunesURL(searchTerm: text, category: category)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { (data, response, error) in
            var success = false
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
                if let data = data {
                    print("Successful!")
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    self.isLoading = false
                    success = true
                }
            } else if !success{
                print("Failure! \(response!)")
                self.hasSearched = false
                self.isLoading = false
            }
            DispatchQueue.main.async {
                completion(success)
            }
        }
        dataTask?.resume()
    }

    private func iTunesURL(searchTerm: String, category: Int) -> URL {
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
