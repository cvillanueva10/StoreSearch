//
//  NothingFoundCell.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/20/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class NothingFoundCell: UITableViewCell {

    let nothingFoundLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing Found"
        label.textAlignment = .center
        label.textColor = UIColor(white: 0, alpha: 0.5)
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    private func configure() {
        selectionStyle = .none
        addSubview(nothingFoundLabel)
        nothingFoundLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nothingFoundLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
