//
//  Extensions.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/20/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

extension UIColor {
    static let barTintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    static let selectedColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
    static let tintColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
}

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { [weak self] (url, response, error)  in
            if error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}
