//
//  MarkdownCodeEscaping.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

// 内联 == 单行
open class MarkdownInlineCodeEscaping: MarkdownElement {

  fileprivate static let regex = "(\\s+|^)(?<!\\\\)(?:\\\\\\\\)*+(\\`+)(.+?)(\\2)"

  open var regex: String {
    return MarkdownInlineCodeEscaping.regex
  }

  open func regularExpression() throws -> NSRegularExpression {
    return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
  }

  open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    guard 3 < match.numberOfRanges else { return }
    
    let range = match.range(at: 3)
    // escaping all characters
    let matchString = attributedString.attributedSubstring(from: range).string

    // 仅处理内联无换行符
    guard matchString.contains(where: { $0 == "\n" }) == false else { return }
    guard let encodString = matchString.encodBase64() else { return }
    
    attributedString.replaceCharacters(in: range, with: encodString)
  }
}
