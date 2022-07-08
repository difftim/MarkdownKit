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
  fileprivate static let regex = "(\\s+|\\w+|^)(?<!\\\\)(?:\\\\\\\\)*+(\\`+)(.+?)(\\2)"
    
  fileprivate static let languageRegex = "\\b[a-zA-Z]+\\b"

  open var regex: String {
    return MarkdownCodeEscaping.regex
  }

  open func regularExpression() throws -> NSRegularExpression {
    return try NSRegularExpression(pattern: regex, options: .dotMatchesLineSeparators)
  }

  open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    guard 2 < match.numberOfRanges else { return }
    
    let range = NSRange(
      location: match.range(at: 2).location,
      length: (2 ... match.numberOfRanges - 1).reduce(0) { $0 + match.range(at: $1).length }
    )
    // escaping all characters
    let matchString = attributedString.attributedSubstring(from: match.range(at: match.numberOfRanges - 2)).string
      
    // 仅处理**含换行符**
    guard matchString.contains(where: { $0 == "\n" }) else { return }
      
    let language = matchLanguageResult(matchString)
      
    attributedString.replaceCharacters(
      in: range,
      with: "[▶ View Code Block](\(MarkdownCodeEscaping.url(lang: language, code: matchString)))"
    )
  }
    
  fileprivate func matchLanguageResult(_ string: String) -> String {
    let attributedString = NSAttributedString(string: string)
    do {
      let regularExpression = try NSRegularExpression(pattern: "\\b[a-zA-Z]+\\b")
      if let match = regularExpression.firstMatch(in: string,
                                                  options: .withoutAnchoringBounds,
                                                  range: NSRange(location: 0,
                                                                 length: attributedString.length))
      {
          return attributedString.attributedSubstring(from: match.range).string
      }
    } catch {}
    return ""
  }
}

public extension MarkdownCodeEscaping {
  private enum Config {
    static let host = "MarkdownCodeEscaping.md"
  }

  static func url(lang: String, code: String) -> String {
    guard let data = code.encodBase64() else { return "" }
    return "http://\(Config.host)?\(lang):\(data)"
  }

  static func code(url: URL) -> (String?, String?) {
    guard let host = url.host, host == Config.host else { return (nil, nil) }
    guard let data = url.query else { return (nil, nil) }
    let contents = data.split(separator: ":").compactMap({ String($0) })
    if let lang = contents.first, let code = contents.last {
      return (lang, code.decodBase64())
    }
    return (nil, nil)
  }
}
