//
//  AlertViewController.swift
//  AlertViewController
//
//  Created by Michael Inger on 26/07/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit


// MARK: - UIAlertController

/// Adds ability to display `UIImage` above the title label of `UIAlertController`.
/// Functionality is achieved by adding “\n” characters to `title`, to make space
/// for `UIImageView` to be added to `UIAlertController.view`. Set `title` as
/// normal but when retrieving value use `originalTitle` property.
class ImageAlertController: UIAlertController {
    /// - Return: value that was set on `title`
    private(set) var originalTitle: String?
    private var spaceAdjustedTitle: String = ""
    private weak var imageView: UIImageView? = nil
    private var previousImgViewSize: CGSize = .zero
    private var imageViewSize: CGSize?

    /// - parameter image: `UIImage` to be displayed about title label
    var titleImage: UIImage? {
        set {
            guard let imageView = self.imageView else {
                let imageView = UIImageView(image: newValue)
                if let size = imageViewSize {
                    imageView.frame.size = size
                }
                self.view.addSubview(imageView)
                self.imageView = imageView
                return
            }
            imageView.image = newValue
        }
        get {
            return imageView?.image
        }
    }

    convenience init(image: UIImage?, size: CGSize? = nil, title: String?, message: String?, preferredStyle: UIAlertControllerStyle) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)

        guard let image = image else { return }
        imageViewSize = size
        titleImage = image
    }

    override var title: String? {
        didSet {
            // Keep track of original title
            if title != spaceAdjustedTitle {
                originalTitle = title
            }
        }
    }
    
    // MARK: -  Layout code
    
    override func viewDidLayoutSubviews() {
        guard let imageView = imageView else {
            super.viewDidLayoutSubviews()
            return
        }
        // Adjust title if image size has changed
        if previousImgViewSize != imageView.bounds.size {
            previousImgViewSize = imageView.bounds.size
            adjustTitle(for: imageView)
        }
        // Position `imageView`
        let linesCount = newLinesCount(for: imageView)
        let padding = Constants.padding(for: preferredStyle)
        imageView.center.x = view.bounds.width / 2.0
        imageView.center.y = padding + linesCount * lineHeight / 2.0
        super.viewDidLayoutSubviews()
    }

    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }

    func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title/*, self.responds(to: Selector(Constants.titleAttributedKey))*/ else { return }

        let attributes: [NSAttributedStringKey: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: Constants.titleAttributedKey)
    }

    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }

    func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message/*, self.responds(to: Selector(Constants.messageAttributedKey))*/ else { return }

        let attributes: [NSAttributedStringKey: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: Constants.messageAttributedKey)
    }
    
    /// Adds appropriate number of "\n" to `title` text to make space for `imageView`
    private func adjustTitle(for imageView: UIImageView) {
        let linesCount = Int(newLinesCount(for: imageView))
        let lines = (0..<linesCount).map({ _ in "\n" }).reduce("", +)
        spaceAdjustedTitle = lines + (originalTitle ?? "")
        title = spaceAdjustedTitle
    }
    
    /// - Return: Number new line chars needed to make enough space for `imageView`
    private func newLinesCount(for imageView: UIImageView) -> CGFloat {
        return ceil(imageView.bounds.height / lineHeight)
    }
    
    /// Calculated based on system font line height
    private lazy var lineHeight: CGFloat = {
        let style: UIFontTextStyle = self.preferredStyle == .alert ? .headline : .callout
        return UIFont.preferredFont(forTextStyle: style).pointSize
    }()
    
    struct Constants {
        static let titleAttributedKey = "attributedTitle"
        static let messageAttributedKey = "attributedMessage"
        static var paddingAlert: CGFloat = 22
        static var paddingSheet: CGFloat = 16
        static func padding(for style: UIAlertControllerStyle) -> CGFloat {
            return style == .alert ? Constants.paddingAlert : Constants.paddingSheet
        }
    }
}


// MARK: - UIAlertAction

/// Adds ability to display image left of the action title, by leveraging KVC.
/// Also checks whether `UIAlertAction` responds to appropriate selector to
/// avoid crashes if property is not available in the future.
extension UIAlertAction {

    convenience init(title: String?, image: UIImage?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.init(title: title, style: style, handler: handler)

        actionImage = image
    }

    /// Image to display left of the action title
    var actionImage: UIImage? {
        get {
            if self.responds(to: Selector(Constants.imageKey)) {
                return self.value(forKey: Constants.imageKey) as? UIImage
            }
            return nil
        }
        set {
            if self.responds(to: Selector(Constants.imageKey)) {
                self.setValue(newValue, forKey: Constants.imageKey)
            }
        }
    }

    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: Constants.titleTextColorKey) as? UIColor
        }
        set {
            self.setValue(newValue, forKey: Constants.titleTextColorKey)
        }
    }

    private struct Constants {
        static let imageKey = "image"
        static let titleTextColorKey = "titleTextColor"
    }
}
