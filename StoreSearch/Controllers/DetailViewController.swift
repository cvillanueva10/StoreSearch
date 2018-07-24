//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/23/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.95)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "CloseButton"), for: .normal)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.init(999), for: .horizontal)
        imageView.backgroundColor = .red
        return imageView
    }()
    let thumbnailImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.init(249), for: .vertical)
        label.text = "Name"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Artist Name"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Type: "
        label.setContentHuggingPriority(.init(999), for: .vertical)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .lightGray
        return label
    }()
    let typeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Type Value"
        label.setContentHuggingPriority(.init(999), for: .vertical)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    let typeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        return stackView
    }()
    let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "Genre: "
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .lightGray
        return label
    }()
    let genreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Genre Value"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    let genreStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        return stackView
    }()
    let priceButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: "$9.99", attributes: [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)
            ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .trailing
//        stackView.distribution = .fillProportionally
        return stackView
    }()
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(popupView)
        popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        popupView.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 2).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 4).isActive = true
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        thumbnailImageStackView.addArrangedSubview(thumbnailImageView)
        typeStackView.addArrangedSubview(typeLabel)
        typeStackView.addArrangedSubview(typeValueLabel)
        genreStackView.addArrangedSubview(genreLabel)
        genreStackView.addArrangedSubview(genreValueLabel)
        priceStackView.addArrangedSubview(priceButton)
        mainStackView.addArrangedSubview(thumbnailImageStackView)
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(artistNameLabel)
        mainStackView.addArrangedSubview(typeStackView)
        mainStackView.addArrangedSubview(genreStackView)
        mainStackView.addArrangedSubview(priceStackView)
        popupView.addSubview(mainStackView)
        mainStackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 4).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 8).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -4).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailImageStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        priceStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        print(123)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - transitioning delegate

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
