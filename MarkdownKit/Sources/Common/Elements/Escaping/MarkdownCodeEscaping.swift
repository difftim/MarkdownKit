//
//  MarkdownCodeEscaping.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

// 多行
open class MarkdownCodeEscaping: MarkdownElement {

  fileprivate static let regex = "(\\s+|^)(?<!\\\\)(?:\\\\\\\\)*+(\\`+)(.+?)(\\2)"

  open var regex: String {
    return MarkdownCodeEscaping.regex
  }

  open func regularExpression() throws -> NSRegularExpression {
    return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
  }

  open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    let range = match.range(at: 3)
    // escaping all characters
    let matchString = attributedString.attributedSubstring(from: range).string

    // 仅处理**含换行符**
    guard matchString.contains(where: { $0 == "\n" }) else { return }


    attributedString.replaceCharacters(
      in: .init(location: match.range(at: 2).location, length: (2...4).reduce(0, { $0 + match.range(at: $1).length })),
      with: "[View Code](\(MarkdownCodeEscaping.url(code: "```\(matchString)```")))"
    )
  }

}

public extension MarkdownCodeEscaping {
  private enum Config {
    static let host = "MarkdownCodeEscaping.md"
  }

  static func url(code: String) -> String {
    let data = encode(code: code)
    return "http://\(Config.host)?\(data)"
  }
  public static func code(url: URL) -> String? {
    guard let host = url.host, host == Config.host else { return nil }
    guard let data = url.query else { return nil }
    return decode(data: data)
  }

  private static func encode(code: String) -> String {
    return code.escapeUTF16()
  }
  private static func decode(data: String) -> String? {
    return data.unescapeUTF16()
  }
}
