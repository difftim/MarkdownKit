//
//  MarkdownBold.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation

open class MarkdownBold: MarkdownCommonElement {
  
  fileprivate static let regex = "(.*?|^)([\\*|_]{2,})(?=\\S)(.+?)(?<=\\S)(\\2)"

  open var font: MarkdownFont?
  open var color: MarkdownColor?

  open var regex: String {
    return MarkdownBold.regex
  }
  
  public init(font: MarkdownFont? = nil, color: MarkdownColor? = nil) {
    self.font = font
    self.color = color
  }

  public func match(_ match: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
    guard 4 < match.numberOfRanges else { return }
    
    attributedString.deleteCharacters(in: match.range(at: 4))

    var attributes = self.attributes

    attributedString.enumerateAttribute(.font, in: match.range(at: 3)) { value, range, _ in
      guard let currentFont = value as? MarkdownFont else { return }
      if let customFont = self.font {
          attributes[.font] = currentFont.isItalic() ? customFont.bold().italic() : customFont.bold()
      } else {
        attributedString.addAttribute(
          NSAttributedString.Key.font,
          value: currentFont.bold(),
          range: range
        )
      }
    }

    attributedString.addAttributes(attributes, range: match.range(at: 3))

    attributedString.deleteCharacters(in: match.range(at: 2))
  }
    
  public func parse(_ attributedString: NSMutableAttributedString) {
    var location = 0
    do {
      let regex = try regularExpression()
      while let regexMatch =
        regex.firstMatch(in: attributedString.string,
                                             options: .withoutAnchoringBounds,
                                             range: NSRange(location: location,
                                              length: attributedString.length - location))
      {
        let oldLength = attributedString.length
        match(regexMatch, attributedString: attributedString)
        let newLength = attributedString.length
        location = regexMatch.range.location + regexMatch.range.length + newLength - oldLength
      }
    } catch { }
    
    if hasRegexMatchs(attributedString) {
        parse(attributedString)
    }
  }
    
  func hasRegexMatchs(_ attributedString: NSMutableAttributedString) -> Bool {
    do {
        let regex = try regularExpression()
        let regexMatchs = regex.matches(in: attributedString.string, options:.withoutAnchoringBounds, range: NSRange(location: 0, length:attributedString.length))
        return regexMatchs.count > 0
    } catch {}
    return false
  }
}
