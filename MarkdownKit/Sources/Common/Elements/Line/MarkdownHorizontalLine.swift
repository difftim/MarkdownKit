//
//  MarkdownHorizontalLine.swift
//  Example iOS
//
//  Created by jone on 2022/7/5.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import Foundation

open class MarkdownHorizontalLine: MarkdownElement {
    fileprivate static let regex = "^([\\t\\r -]*?)(-{3,})([\\t\\r -]*?)$"

    lazy var textAttach: NSTextAttachment = {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let lineHeight = font.lineHeight
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 2000, height: lineHeight))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        let img = UIImage.image(color: .gray, andRect: CGRect(x: 0, y: 0, width: 2000, height: 1))
        imageView.image = img
        let newImage = UIImage.image(from: imageView)
        let textAttachment = NSTextAttachment()
        textAttachment.image = newImage
        return textAttachment
    }()

    open var regex: String {
        return MarkdownHorizontalLine.regex
    }

    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
    }

    public init() {}

    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let attString = NSAttributedString(attachment: textAttach)
        attributedString.replaceCharacters(in: match.range, with: attString)
    }
}
