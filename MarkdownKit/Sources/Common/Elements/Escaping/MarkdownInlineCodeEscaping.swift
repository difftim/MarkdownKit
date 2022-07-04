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
    let range = match.range(at: 3)
    // escaping all characters
    let matchString = attributedString.attributedSubstring(from: range).string

    // 仅处理内联无换行符
    guard matchString.contains(where: { $0 == "\n" }) == false else { return }

    let escapedString = [UInt16](matchString.utf16)
      .map { (value: UInt16) -> String in String(format: "%04x", value) }
      .reduce("") { (string: String, character: String) -> String in
        return "\(string)\(character)"
    }
    attributedString.replaceCharacters(in: range, with: escapedString)
  }

}
