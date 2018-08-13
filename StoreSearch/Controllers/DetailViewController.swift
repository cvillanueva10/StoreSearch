//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/23/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController, UINavigationControllerDelegate {

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
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded {
                updateUI(with: searchResult)
            }
        }
    }
    var isIpadSizeClass: Bool {
        let rootTraitCollection = view.window?.rootViewController?.traitCollection
        return rootTraitCollection?.horizontalSizeClass == .regular && rootTraitCollection?.verticalSizeClass == .regular
    }
    var isIphonePlusSizeClass: Bool {
        let rootTraitCollection = view.window?.rootViewController?.traitCollection
        return rootTraitCollection?.horizontalSizeClass == .regular && rootTraitCollection?.verticalSizeClass == .compact
    }
    var downloadTask: URLSessionDownloadTask?
    var dismissStyle = AnimationStyle.fade
    var isPopup = false

    var popupWidth: CGFloat {
        return isIpadSizeClass ? 500 : 240
    }
    var thumbnailImageViewSize: CGFloat {
        return isIpadSizeClass ? 180 : 100
    }
    var stackViewVerticalSpacing: CGFloat {
        return isIpadSizeClass ? 16 : 4
    }
    var topMarginPadding: CGFloat {
        return isIpadSizeClass ? 20 : 8
    }
    var priceButtonSpacing: CGFloat {
        return isIpadSizeClass ? 20 : 8
    }


    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
          setupUI()
    }

    deinit {
        downloadTask?.cancel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

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
        popupView.isHidden = false
    }

    func setupUI() {
        title = "Store Search"
        if isPopup {
            let dismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
            dismissGestureRecognizer.cancelsTouchesInView = false
            dismissGestureRecognizer.delegate = self
            view.addGestureRecognizer(dismissGestureRecognizer)
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "LandscapeBackground"))
            popupView.isHidden = true
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(showPopoverMenu))
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        view.addSubview(popupView)
        popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        popupView.widthAnchor.constraint(greaterThanOrEqualToConstant: popupWidth).isActive = true
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
        mainStackView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: topMarginPadding).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 8).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -8).isActive = true
        mainStackView.spacing = stackViewVerticalSpacing
        // override intrinsic sizes
        genreLabel.lastBaselineAnchor.constraint(equalTo: genreValueLabel.lastBaselineAnchor).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: thumbnailImageViewSize).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalToConstant: thumbnailImageViewSize).isActive = true
        thumbnailImageStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        priceStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        priceButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        priceButton.contentEdgeInsets = UIEdgeInsetsMake(0, priceButtonSpacing, 0, priceButtonSpacing)
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        priceButton.addTarget(self, action: #selector(openInStore), for: .touchUpInside)
        if !isIpadSizeClass && !isIphonePlusSizeClass {
            popupView.addSubview(closeButton)
            closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 2).isActive = true
            closeButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 4).isActive = true
        }
    }

    // MARK: - actions

    @objc private func showPopoverMenu(_ sender: UIBarButtonItem) {
        let popoverMenuViewController = PopoverMenuViewController(style: .grouped)
        popoverMenuViewController.modalPresentationStyle = .popover
        popoverMenuViewController.popoverPresentationController?.delegate = self
        popoverMenuViewController.popoverPresentationController?.sourceView = view
        popoverMenuViewController.popoverPresentationController?.barButtonItem = sender
        popoverMenuViewController.preferredContentSize = CGSize(width: 320, height: 204)
        popoverMenuViewController.delegate = self
        present(popoverMenuViewController, animated: true, completion: nil)
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

// MARK: - popover delegate

extension DetailViewController: PopoverMenuViewControllerDelegate {

    func menuViewControllerSendEmail(_ controller: PopoverMenuViewController) {
        dismiss(animated: true) {
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                controller.delegate = self
                controller.setSubject(NSLocalizedString("Support Request",
                                                        comment: "Email subject"))
                controller.setToRecipients(["your@email-address-here.com"])
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - mail composter delegate

extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller:
        MFMailComposeViewController, didFinishWith result:
        MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UIPopoverPresentationControllerDelegate {
}




