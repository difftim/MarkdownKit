//
//  MarkdownQuote.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownQuote: MarkdownElement, MarkdownStyle {

  fileprivate static let regex = "^(>{1,} {1,})([\\s\\S]+?)(?=(\\n{2})|( {0,}\\d\\.)|( {0,}[\\+-])|(>))"

  open var font: MarkdownFont?
  open var color: MarkdownColor?

  open var regex: String {
    return MarkdownQuote.regex
  }
  
  public init(font: MarkdownFont? = nil,
              color: MarkdownColor? = nil) {
    self.font = font
    self.color = color
  }
  
  open func regularExpression() throws -> NSRegularExpression {
    return try NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
  }

  open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange) {
    attributedString.deleteCharacters(in: range)
  }
  
  private func defaultParagraphStyle() -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.firstLineHeadIndent = 16
    paragraphStyle.headIndent = 16
    paragraphStyle.tag = 10
    return paragraphStyle
  }
  
  private func attributes() -> [NSAttributedString.Key: AnyObject] {
    var attributes = self.attributes
    attributes[NSAttributedString.Key.paragraphStyle] = defaultParagraphStyle()
    return attributes
  }
}

extension MarkdownQuote {
  func addAttributes(_ attributedString: NSMutableAttributedString, range: NSRange) {
    attributedString.addAttributes(attributes(), range: range)
  }
  
  open func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    guard 2 < match.numberOfRanges else { return }
    
    addAttributes(attributedString, range: match.range(at: 2))
    formatText(attributedString, range: match.range(at: 1))
  }
  
  public func parse(_ attributedString: NSMutableAttributedString) {
    attributedString.append(NSAttributedString(string: "\n\n"))
    var location = 0
    do {
      let regex = try regularExpression()
      while let regexMatch = regex.firstMatch(in: attributedString.string,
                                              options: .withoutAnchoringBounds,
                                              range: NSRange(location: location,
                                                             length: attributedString.length - location)) {
        let oldLength = attributedString.length
        match(regexMatch, attributedString: attributedString)
        let newLength = attributedString.length
        location = regexMatch.range.location + regexMatch.range.length + newLength - oldLength
      }
    } catch { }
    attributedString.deleteCharacters(in: NSRange(location: attributedString.length - 2, length: 2))
  }
}
