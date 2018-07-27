//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/23/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    enum AnimationStyle {
        case slide
        case fade
    }
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
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        return label
    }()
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Type: "
        label.setContentHuggingPriority(.init(999), for: .vertical)
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        return label
    }()
    let typeValueLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.init(999), for: .vertical)
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
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
        label.setContentHuggingPriority(.init(999), for: .vertical)
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        return label
    }()
    let genreValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
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
            NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)
            ])
        button.setBackgroundImage(#imageLiteral(resourceName: "PriceButton"), for: .normal)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .trailing
        return stackView
    }()
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    var searchResult: SearchResult? {
        didSet {
            if let searchResult = searchResult {
                updateUI(with: searchResult)
            }
        }
    }
    var downloadTask: URLSessionDownloadTask?
    var dismissStyle = AnimationStyle.fade


    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    deinit {
        downloadTask?.cancel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUI(with searchResult: SearchResult) {
        if let url = URL(string: searchResult.imageLarge) {
            downloadTask = thumbnailImageView.loadImage(url: url)
        }
        nameLabel.text = searchResult.name
        artistNameLabel.text = searchResult.artistName
        typeValueLabel.text = searchResult.type
        genreValueLabel.text = searchResult.genre
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        let attributedTitle = NSAttributedString(string: priceText, attributes: [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)
            ])
        priceButton.setAttributedTitle(attributedTitle, for: .normal)
        priceButton.setTitle(priceText, for: .normal)
    }

    func setupUI() {
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        view.addSubview(popupView)
        let dismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        dismissGestureRecognizer.cancelsTouchesInView = false
        dismissGestureRecognizer.delegate = self
        view.addGestureRecognizer(dismissGestureRecognizer)
        popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        popupView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        popupView.layer.cornerRadius = 10
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
        mainStackView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 8).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 8).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -8).isActive = true
        // override intrinsic sizes
        genreLabel.lastBaselineAnchor.constraint(equalTo: genreValueLabel.lastBaselineAnchor).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailImageStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        priceStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        priceButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        priceButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4)
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        priceButton.addTarget(self, action: #selector(openInStore), for: .touchUpInside)
        popupView.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 2).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 4).isActive = true
    }

    @objc private func openInStore() {
        if let storeUrl = searchResult?.storeUrl, let url = URL(string: storeUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc private func handleDismiss() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - gesture recognizer delegates
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view
    }
}

// MARK: - transitioning delegates

extension DetailViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
}
