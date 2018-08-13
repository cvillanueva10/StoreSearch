
//
//  PopoverMenuViewController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 8/12/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

protocol PopoverMenuViewControllerDelegate: class {
    func menuViewControllerSendEmail(_ controller: PopoverMenuViewController)
}

class PopoverMenuViewController: UITableViewController {

    weak var delegate: PopoverMenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentSize = CGSize(width: 320, height: 204)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Send Support Email"
        case 1:
            cell.textLabel?.text = "Rate This App"
        case 2:
            cell.textLabel?.text = "About"
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendEmail(self)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
