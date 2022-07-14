//
//  MarkdownOrderList.swift
//  MarkdownKit
//
//  Created by user on 2022/7/8.
//  Copyright © 2022 Ivan Bruel. All rights reserved.
//

import Foundation

open class MarkdownOrderList: MarkdownElement, MarkdownStyle {
  
  var index: Int = 0

  fileprivate static let regex = "^([ ]{0,2}(\\d{1,9})\\.)[ ]+(.+)$"

  open var font: MarkdownFont?
  open var color: MarkdownColor?

  open var regex: String {
    return MarkdownOrderList.regex
  }

  public init(font: MarkdownFont? = nil,
              color: MarkdownColor? = nil) {
    self.font = font
    self.color = color
  }

  open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
    let indicator = "\(index). "
    attributedString.replaceCharacters(in: range, with: indicator)
    let updatedRange = NSRange(location: range.location, length: indicator.utf16.count)
    attributedString.addAttributes([.paragraphStyle : paragraphStyle(indicator.utf16.count)], range: updatedRange)
  }

  private func paragraphStyle(_ indent: Int) -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.firstLineHeadIndent = 0
    paragraphStyle.headIndent = 16
    paragraphStyle.paragraphSpacing = 4
    return paragraphStyle
  }
}

extension MarkdownOrderList {
  public func regularExpression() throws -> NSRegularExpression {
    return try NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
  }
  
  func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange) {
    attributedString.addAttributes(attributes, range: range)
  }
  
  public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    guard 3 < match.numberOfRanges else { return }
    if index == 0 {
      index = Int(attributedString.attributedSubstring(from: match.range(at: 2)).string) ?? 0
    } else {
      index += 1
    }
    let level = match.range(at: 1).length
    addAttributes(attributedString, range: match.range(at: 3))
    let range = NSRange(location: match.range(at: 1).location,
                        length: match.range(at: 3).location - match.range(at: 1).location)
    formatText(attributedString, range: range, level: level)
  }
}
