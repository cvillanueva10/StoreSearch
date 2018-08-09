//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/27/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "LandscapeBackground"))
        sv.isPagingEnabled = true
        return sv
    }()
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 0
        pc.tintColor = .white
        return pc
    }()
    var searchResults = [SearchResult]()
    var search: Search!
    private var isFirstTime = true
    private var downloads = [URLSessionDownloadTask]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        scrollView.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.height - pageControl.frame.size.height - 20,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        if isFirstTime {
            isFirstTime = false
            switch search.state {
            case .notSearchedYet:
                break
            case .loading:
                break
            case .noResults:
                break
            case .results(let list):
                tileButtons(list)
            }
        }
    }

    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel()
        }
    }

    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        guard let url = URL(string: searchResult.imageSmall) else { return }
        let task = URLSession.shared.downloadTask(with: url) { [weak button] (url, response, error) in
            if error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let button = button {
                        button.setImage(image, for: .normal)
                    }
                }
            }
        }
        task.resume()
        downloads.append(task)
    }

    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20

        let viewWidth = scrollView.bounds.size.width

        switch viewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorizontal = (itemWidth - buttonWidth) / 2
        let paddingVertical = (itemHeight - buttonHeight) / 2
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: result, andPlaceOn: button)
            button.frame = CGRect(x: x + paddingHorizontal,
                                  y: marginY + CGFloat(row) * itemHeight + paddingVertical,
                                  width: buttonWidth,
                                  height: buttonHeight)
            scrollView.addSubview(button)
            row += 1
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth,
                                        height: scrollView.bounds.size.height)
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        print("Number of pages: \(numPages)")
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page

    }
}






