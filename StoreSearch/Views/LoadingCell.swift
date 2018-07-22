//
//  LoadingCell.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/22/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textAlignment = .center
        label.textColor = UIColor(white: 0, alpha: 0.5)
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let indiciator = UIActivityIndicatorView()
        indiciator.activityIndicatorViewStyle = .gray
        indiciator.tag = 100
        return indiciator
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    func configure() {
        mainStackView.addArrangedSubview(loadingLabel)
        mainStackView.addArrangedSubview(activityIndicatorView)
        addSubview(mainStackView)
        mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
