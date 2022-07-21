//
//  MarkdownHorizontalLine.swift
//  Example iOS
//
//  Created by jone on 2022/7/5.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import Foundation

open class MarkdownHorizontalLine: MarkdownElement {
    fileprivate static let regex = "^([\\t\\r -]*?)(-{2,})([\\t\\r -]*?)$"

    open var regex: String {
        return MarkdownHorizontalLine.regex
    }

    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
    }

    public init() {}

    public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        let attString = NSAttributedString(attachment: UIImage.lineAttach())
        attributedString.replaceCharacters(in: match.range, with: attString)
    }
}
