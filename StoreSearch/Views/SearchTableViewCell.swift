//
//  SearchTableViewCell.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/20/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .preferredFont(forTextStyle: .title3)
        return label
    }()

    let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Artist Name"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = UIColor.init(white: 0, alpha: 0.5)
        return label
    }()

    let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Placeholder")
        return imageView
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }

    private func configureCell() {
        let selectedView = UIView(frame: .zero)
        selectedView.backgroundColor = .selectedColor
        selectedBackgroundView = selectedView
        labelStackView.addArrangedSubview(topLabel)
        labelStackView.addArrangedSubview(bottomLabel)
        mainStackView.addArrangedSubview(thumbnailImageView)
        mainStackView.addArrangedSubview(labelStackView)
        addSubview(mainStackView)
        mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor,
                                               constant: 4).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor,
                                                constant: -4).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        // Intrinsic sizes
        thumbnailImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 3/4).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor).isActive = true
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
